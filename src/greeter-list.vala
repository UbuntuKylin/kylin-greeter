/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2012 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Robert Ancell <robert.ancell@canonical.com>
 *          Michael Terry <michael.terry@canonical.com>
 *          Scott Sweeny <scott.sweeny@canonical.com>
 */

private int get_grid_offset (int size)
{
    return (int) (size % grid_size) / 2;
}

[DBus (name="com.canonical.UnityGreeter.List")]
public class ListDBusInterface : Object
{
    private GreeterList list;

    public ListDBusInterface (GreeterList list)
    {
        this.list = list;
        this.list.entry_selected.connect ((name) => {
            entry_selected (name);
        });
    }

    public string get_active_entry ()
    {
        string entry = "";

        if (list.selected_entry != null && list.selected_entry.id != null)
            entry = list.selected_entry.id;

        return entry;
    }

    public void set_active_entry (string entry_name)
    {
        list.set_active_entry (entry_name);
    }

    public signal void entry_selected (string entry_name);
}

public abstract class GreeterList : FadableBox
{
    public Background background { get; construct; }
    
    public PromptBox? selected_entry { get; private set; default = null; }
    public bool start_scrolling { get; set; default = true; }

    protected string greeter_authenticating_user;

    protected bool _always_show_manual = false;
    public bool always_show_manual
    {
        get { return _always_show_manual; }
        set
        {
            _always_show_manual = value;
            if (value)
                add_manual_entry ();
            else if (have_entries ())
                remove_entry ("*other");
        }
    }

    protected List<PromptBox> entries = null;

    private ListDBusInterface dbus_object;

    private double scroll_target_location;
    private double scroll_start_location;
    private double scroll_location;
    private double scroll_direction;

    private int clicked_location = -1;
    private AnimateTimer scroll_timer;

    private Gtk.Fixed fixed;
    public DashBox greeter_box;
    private int cached_box_height = -1;

    protected enum Mode
    {
        ENTRY,
        SCROLLING,
    }
    protected Mode mode = Mode.ENTRY;

    public enum Status
    {
        USERLIST,
        LOGINBOX,
        SESSIONLIST,
    }
    public  Status status = Status.USERLIST;
    protected Status status_box=Status.USERLIST;
    
    public static const int BORDER = 4;
    public static const int BOX_WIDTH = 2; /* in grid_size blocks */
    public static const int LOGINBOX_WIDTH = 12;
    public static const int DEFAULT_BOX_HEIGHT = 2; /* in grid_size blocks */
    public static const int DEFAULT_LOGINBOX_HEIGHT = 4;
    private int n_above = 5;//每行中项目个数
    private int n_below = 3;//行数

    private int space_col = 20;
    private int space_row = 10;
    private int box_x
    {
        get { return 0; }
    }

    private int box_y
    {
        get
        {
            /* First, get grid row number as if buttonbox weren't there */
            //var row = (MainWindow.BUTTONBOX_HEIGHT + get_allocated_height ()) / grid_size;
            //row = row - DEFAULT_BOX_HEIGHT; /* and no default dash box */
            //row = row / 2; /* and in the middle */
            /* Now calculate y pixel spot keeping in mind buttonbox's allocation */
            //return row * grid_size - MainWindow.BUTTONBOX_HEIGHT;
            return 0;
        }
    }

    public signal void entry_selected (string? name);
    public signal void entry_displayed_start ();
    public signal void entry_displayed_done ();

    
    
    protected virtual string? get_selected_id ()
    {
        if (selected_entry == null)
            return null;
        return selected_entry.id;
    }

    private string? _manual_name = null;
    public string? manual_name
    {
        get { return _manual_name; }
        set
        {
            _manual_name = value;
            if (find_entry ("*other") != null)
                add_manual_entry ();
        }
    }

    private PromptBox _scrolling_entry = null;
    private PromptBox scrolling_entry
    {
        get { return _scrolling_entry; }
        set
        {
            /* When we swap out a scrolling entry, make sure to hide its
             * image button, else it will appear in the tab chain. */
            if (_scrolling_entry != null)
                _scrolling_entry.set_options_image (null);
            _scrolling_entry = value;
        }
    }

    public GreeterList (Background bg)
    {
        Object (background: bg);
    }

    construct
    {
        can_focus = false;
        visible_window = false;

        fixed = new Gtk.Fixed ();
        fixed.show ();
        add (fixed);

        greeter_box = new DashBox (background);
        greeter_box.notify["base-alpha"].connect (() => { queue_draw (); });
        greeter_box.show ();
        //greeter_box.size_allocate.connect (greeter_box_size_allocate_cb);
        add_with_class (greeter_box);

        scroll_timer = new AnimateTimer (AnimateTimer.ease_out_quint, AnimateTimer.FAST);
        scroll_timer.animate.connect (animate_scrolling);

        status_box=Status.LOGINBOX;

         UnityGreeter.singleton.greeter_already.connect (greeter_already_cb);
        try
        {
            Bus.get.begin (BusType.SESSION, null, on_bus_acquired);
        }
        catch (IOError e)
        {
            debug ("Error getting session bus: %s", e.message);
        }
    }

    private void on_bus_acquired (Object? obj, AsyncResult res)
    {
        try
        {
            var conn = Bus.get.end (res);
            this.dbus_object = new ListDBusInterface (this);
            conn.register_object ("/list", this.dbus_object);
        }
        catch (IOError e)
        {
            debug ("Error registering user list dbus object: %s", e.message);
        }
    }

    public enum ScrollTarget
    {
        START,
        END,
        UP,
        DOWN,
        LEFT,
        RIGHT,
    }

    /*public override void get_preferred_width (out int min, out int nat)
    {
        base.get_preferred_width (out min, out nat);
        //min = BOX_WIDTH * grid_size;
        //nat = BOX_WIDTH * grid_size;
    }*/


    private void greeter_already_cb ()
    {
        if (entries.length()==1)
        {
            debug("only one user,show login box!");
            entry_clicked_cb(entries.nth_data (0));
        }

    }
    public override void get_preferred_height (out int min, out int nat)
    {
        base.get_preferred_height (out min, out nat);
        min = 0;
    }

    public void cancel_authentication ()
    {
        UnityGreeter.singleton.cancel_authentication ();
        entry_selected (selected_entry.id);
    }

    public void scroll (ScrollTarget target)
    {   debug("~~~~~~~~~scroll ");
        if (!sensitive)
            return;
        if(status==Status.LOGINBOX)
            return;
        switch (target)
        {
        case ScrollTarget.START:
            select_entry (entries.nth_data (0), -1.0);
            break;
        case ScrollTarget.END:
            select_entry (entries.nth_data (entries.length () - 1), 1.0);
            break;
        case ScrollTarget.LEFT:
            var index = entries.index (selected_entry) - 1;
            if (index < 0)
                index = 0;
            select_entry (entries.nth_data (index), -1.0);
            break;
        case ScrollTarget.RIGHT:
            var index = entries.index (selected_entry) + 1;
            if (index >= (int) entries.length ())
                index = (int) entries.length () - 1;
            select_entry (entries.nth_data (index), 1.0);
            break;
        case ScrollTarget.UP:
            var index = entries.index (selected_entry) - n_above;
            if (index < 0)
                break;
            select_entry (entries.nth_data (index), -1.0);
            break;
        case ScrollTarget.DOWN:
            var index = entries.index (selected_entry) + n_above;
            if (index >= (int) entries.length ())
                break;
            select_entry (entries.nth_data (index), 1.0);
            break;
            
        }
    }

    protected void add_with_class (Gtk.Widget widget)
    {
        fixed.add (widget);
        UnityGreeter.add_style_class (widget);
    }

    protected void redraw_greeter_box ()
    {
        Gtk.Allocation allocation;
        greeter_box.get_allocation (out allocation);
        queue_draw_area (allocation.x, allocation.y, allocation.width, allocation.height);
    }

    public void show_message (string text, bool is_error = false)
    {
        if (will_clear)
        {
            selected_entry.clear ();
            will_clear = false;
        }

        selected_entry.add_message (text, is_error);
    }

    public DashEntry add_prompt (string text, bool secret = false)
    {
        if (will_clear)
        {
            selected_entry.clear ();
            will_clear = false;
        }

        string accessible_text = null;
        if (selected_entry != null && selected_entry.label != null)
            accessible_text = _("Enter password for %s").printf (selected_entry.label);
        var prompt = selected_entry.add_prompt (text, accessible_text, secret);

        if (mode != Mode.SCROLLING)
            selected_entry.show_prompts ();

        focus_prompt ();
        redraw_greeter_box ();

        return prompt;
    }

    public Gtk.ComboBox add_combo (GenericArray<string> texts, bool read_only)
    {
        if (will_clear)
        {
            selected_entry.clear ();
            will_clear = false;
        }

        var combo = selected_entry.add_combo (texts, read_only);

        focus_prompt ();
        redraw_greeter_box ();

        return combo;
    }

    public override void grab_focus ()
    {
        focus_prompt ();
    }

    public virtual void focus_prompt ()
    {
        selected_entry.sensitive = true;
        selected_entry.grab_focus ();
    }

    public abstract void show_authenticated (bool successful = true);

    protected PromptBox? find_entry (string id)
    {
        foreach (var entry in entries)
        {
            if (entry.id == id)
                return entry;
        }

        return null;
    }

    protected static int compare_entry (PromptBox a, PromptBox b)
    {
        if (a.id.has_prefix ("*") || b.id.has_prefix ("*"))
        {
           /* Special entries go after normal ones */
           if (!a.id.has_prefix ("*"))
               return -1;
           if (!b.id.has_prefix ("*"))
               return 1;

           /* Manual comes before guest */
           if (a.id == "*other")
               return -1;
           if (a.id == "*guest")
               return 1;
        }

        /* Alphabetical by label */
        return a.label.ascii_casecmp (b.label);
    }

    protected bool have_entries ()
    {
        foreach (var e in entries)
        {
            if (e.id != "*other")
                return true;
        }
        return false;
    }

    protected virtual void insert_entry (PromptBox entry)
    {
        entries.insert_sorted (entry, compare_entry);
    }

    protected abstract void add_manual_entry ();

    protected void add_entry (PromptBox entry)
    {
        entry.expand = true;
        entry.set_size_request (grid_size * BOX_WIDTH - BORDER * 2, -1);
        add_with_class (entry);

        insert_entry (entry);

        entry.name_clicked.connect (entry_clicked_cb);
        entry.back_userlist.connect(back_userlist_cb);
        debug("~~~~~~~add_entry ");
        if (selected_entry == null)
            select_entry (entry, 1.0);
        else
            select_entry (selected_entry, 1.0);

        move_names ();
    }

    public void set_active_entry (string ?name)
    {
        var e = find_entry (name);
        if (e != null)
        {
            var direction = 1.0;
            if (selected_entry != null &&
                entries.index (selected_entry) > entries.index (e))
            {
                direction = -1.0;
            }
            debug("~~~~~~~~~set_active_entry");
            select_entry (e, direction);
        }
    }

    public void set_active_first_entry_with_prefix (string prefix)
    {
        foreach (var e in entries)
        {
            if (e.id.has_prefix (prefix))
            {
                select_entry (e, 1.0);
                break;
            }
        }
    }

    public void remove_entry (string? name)
    {
        remove_entry_by_entry (find_entry (name));
    }

    public void remove_entries_with_prefix (string prefix)
    {
        int i = 0;
        while (i < entries.length ())
        {
            PromptBox e = entries.nth_data (i);
            if (e.id.has_prefix (prefix))
                remove_entry_by_entry (e);
            else
                i++;
        }
    }

    public void remove_entry_by_entry (PromptBox? entry)
    {
        if (entry == null)
            return;

        var index = entries.index (entry);
        entry.destroy ();
        entries.remove (entry);

       /* Select another entry if the selected one was removed */
        if (entry == selected_entry)
        {
            if (index >= entries.length () && index > 0)
                index--;
            else if (index < entries.length ())
                index++;
            
            if (entries.nth_data (index) != null)
                select_entry (entries.nth_data (index), -1.0);
            else if (entries.length() != 0)
                select_entry (entries.nth_data (0), -1.0);
            else
                selected_entry=null;
            //back userlist if in login
            if (status != Status.USERLIST)
                back_userlist_cb();
        }

        /* Show a manual login if no users and no remote login entry */
        if (!have_entries () && !UnityGreeter.singleton.show_remote_login_hint ())
            add_manual_entry ();

        queue_draw ();
    }

    protected int get_greeter_box_height ()
    {
        int height;
        greeter_box.get_preferred_height (null, out height);
        return height;
    }

    protected int get_greeter_box_height_grids ()
    {
        int height = get_greeter_box_height ();
        return height / grid_size + 1; /* +1 because we'll be slightly under due to BORDER */
    }

    protected int get_greeter_box_x ()
    {
        return box_x + BORDER;
    }

    protected int get_greeter_box_y ()
    {
        return box_y + BORDER;
    }

    protected virtual int get_position_y (double position)
    {
        // Most position heights are just the grid height.  Except for the
        // greeter box itself.
        //int box_height = get_greeter_box_height_grids () * grid_size;
        double offset;

        //if (position < 0)
            offset = position * grid_size;
        /*else if (position < 1)
            offset = position * box_height;
        else
            offset = (position - 1) * grid_size + box_height;*/

        return box_y + (int)Math.round(offset);
    }

    private void move_entry (PromptBox entry, int position ,int sum_num)
    {
        //debug("~~~~~~~~~move_entry");
        var alpha = 1.0;
        int col_num;
        int row_num;
        /*if (position < 0)
            alpha = 1.0 + position / (n_above + 1);
        else
            alpha = 1.0 - position / (n_below + 1);*/
        entry.set_alpha (alpha);
        if(sum_num <= n_above)
            col_num = sum_num;
        else
            col_num = n_above;
        row_num = sum_num / n_above;
        if(sum_num % n_above != 0)
            row_num++;
        if(row_num > n_below)
            row_num = n_below;
        var row = position / n_above ;
        var col = position % n_above ;
        //debug("~~~~~~~~~~move_entry position=%d,row=%d,col=%d",position,row,col);
        /* Some entry types may care where they are (e.g. wifi prompt) */
        entry.position = position;

        Gtk.Allocation allocation;
        get_allocation (out allocation);

        var child_allocation = Gtk.Allocation ();
        int user_box_width = (allocation.height - MainWindow.BUTTONBOX_HEIGHT) /5;
        int login_box_width = grid_size * LOGINBOX_WIDTH;
        if (user_box_width<10)
            user_box_width=10;
        entry.set_face_size (user_box_width);
        if(status==Status.LOGINBOX||status==Status.SESSIONLIST)
        {
            //child_allocation.height =128;
            child_allocation.width = login_box_width;//grid_size * LOGINBOX_WIDTH - BORDER * 2;
            entry.get_preferred_height(null, out child_allocation.height);
        }else{
            child_allocation.width = user_box_width;//grid_size * BOX_WIDTH - BORDER * 2;
            entry.get_preferred_height_for_width (child_allocation.width, null, out child_allocation.height);
        }
        
        
           //debug ("move_entry~~~~~~~~~~allocation.height=%d~~allocation.width=%d",allocation.height,allocation.width);
        int x_offset = (allocation.width - child_allocation.width * col_num - (space_col * (col_num -1))) / 2 ;
        int y_offset = (allocation.height - child_allocation.height * row_num - (space_row * (row_num -1))) /2 - MainWindow.BUTTONBOX_HEIGHT /2;
        if(x_offset<0)
            x_offset=0;
        if(y_offset<0)
            y_offset=0;
        child_allocation.x = allocation.x + x_offset + col * (child_allocation.width + space_col);
        if(status!=Status.USERLIST||row_num < n_below)
            child_allocation.y = allocation.y + y_offset + row * (child_allocation.height + space_row);
        else
            child_allocation.y = allocation.y + y_offset + space_row + row * (child_allocation.height + space_row);
        fixed.move (entry, child_allocation.x, child_allocation.y);
        //debug("~~~entry.id=%s~~~~~~~~child_allocation.x=%d~~~child_allocation.y=%d~~~y_offset=%d~~~allocation.y=%d~~~child_allocation.height=%d",entry.id,child_allocation.x,child_allocation.y,y_offset,allocation.y,child_allocation.height);
        //entry.set_face_size (child_allocation.width);
        entry.size_allocate (child_allocation);
    }

    public void greeter_box_size_allocate_cb (Gtk.Allocation allocation)
    {
        /* If the greeter box allocation changes while not moving fix the entries position */
        if (scrolling_entry == null && allocation.height != cached_box_height)
        {
            /* We run in idle because it's kind of a recursive loop and
             * ends up positioning the entries in the wrong place if we try
             * to do it during an existing allocation. */
            Idle.add (() => { move_names (); return false; });
        }
        cached_box_height = allocation.height;
    }

    public void move_names ()
    {
        //debug("~~~~~~~~~move_names,status=%d,",status);
        if(status==Status.LOGINBOX)
        {
            foreach(var entry in entries)
            {
                
                    move_entry (entry,0 ,1);
                if(entries.index(entry)!=clicked_location)
                    entry.hide();
            }
            queue_draw ();
            return;
        }
        int index = 0;
        int last_position = n_above * n_below -1;
        var row = ((int)scroll_location) / n_above ;
        //var col = ((int)scroll_location) % n_above ;
        int sum_num = (int)entries.length();

        Gtk.Allocation allocation;
        get_allocation (out allocation);
        space_col=allocation.width /40;
        if(sum_num<n_above)
        {
            space_col=space_col * (n_above + 1-sum_num);
        }
        if(row > n_below-1)
            last_position = (row+1) * n_above -1;
        foreach (var entry in entries)
        {   //debug("~~~~~~~~~scroll_location = %f ",scroll_location);
            int position =index-(last_position - n_above * n_below);
            
            /* Draw entries above, in and below the box */
            if (position>0&&position<n_above * n_below + 1)
            {
                move_entry (entry, position-1, sum_num);
                // Sometimes we will be overlayed by another widget like the
                // session chooser.  In such cases, don't try to show ourselves
                /*var is_hidden = (position == 0 && greeter_box.has_base &&
                                 greeter_box.base_alpha == 0.0);
                if (!is_hidden)*/
               
               //if(scroll_location == index)
                    //entry.set_name_color_red();
                //    entry.hide();
                //else
                    //entry.set_name_color_default();
                entry.show ();
            }
            else
                entry.hide ();

            index++;
        }
        queue_draw ();
    }

    private void animate_scrolling (double progress)
    {
        /* Total height of list */
        var h = entries.length ();

        /* How far we have to go in total, either up or down with wrapping */
        var distance = scroll_target_location - scroll_start_location;
        if (scroll_direction * distance < 0)
            distance += scroll_direction * h;

        /* How far we've gone so far */
        distance *= progress;

        /* Go that far and wrap around */
        scroll_location = scroll_start_location + distance;
        if (scroll_location > h)
            scroll_location -= h;
        if (scroll_location < 0)
            scroll_location += h;

        move_names ();

        if (progress >= 0.975 && !greeter_box.has_base)
        {
            //setup_prompt_box ();
            entry_displayed_start ();
        }

        /* Stop when we get there */
        if (progress >= 1.0)
            finished_scrolling ();
    }

    private void finished_scrolling ()
    {
        scrolling_entry = null;
        //selected_entry.show_prompts (); /* set prompts to be visible immediately */
        focus_prompt ();
        entry_displayed_done ();
        mode = Mode.ENTRY;
    }

    protected void select_entry (PromptBox entry, double direction, bool do_scroll = false)
    {
        if (!get_realized ())
        {
            /* Just note it for the future if we haven't been realized yet */
            selected_entry = entry;
            return;
        }

        if (scroll_target_location != entries.index (entry))
        {
            var new_target = entries.index (entry);
            var new_direction = direction;
            var new_start = scroll_location;

            if (scroll_location != new_target && do_scroll)
            {
               // var new_distance = new_direction * (new_target - new_start);
                /* Base rate is 350 (250 + 100).  If we find ourselves going further, slow down animation */
               // scroll_timer.reset (250 + int.min ((int)(100 * (Math.fabs (new_distance))), 500));

               // mode = Mode.SCROLLING;
            }

            scrolling_entry = selected_entry;
            scroll_target_location = new_target;
            scroll_direction = new_direction;
            scroll_start_location = new_start;
        }

        if (selected_entry != entry)
        {
            //greeter_box.set_base (null);
            //if (selected_entry != null)
            //    selected_entry.clear ();

            selected_entry = entry;
            greeter_box.set_base (selected_entry);
            //entry_selected (selected_entry.id);

            if (mode == Mode.ENTRY)
            {   debug("~~~~~~~~~select_entry,entry=%s",entry.id);
                // don't need to move, but make sure we trigger the same side effects
                //setup_prompt_box ();
                scroll_timer.reset (0);
            }
        }
    }

    protected virtual void setup_prompt_box (bool fade = false)
    {   debug("~~~~~~~~setup_prompt_box ,and selected_entry = %s",selected_entry.id);
        greeter_box.set_base (selected_entry);
        selected_entry.add_static_prompts ();
        if (fade)
            selected_entry.fade_in_prompts ();
        else
            selected_entry.show_prompts ();
    }

    public override void realize ()
    {
        base.realize ();

        /* NOTE: This is going to cause the entry_selected signal to be emitted even if selected_entry has not changed */
        var saved_entry = selected_entry;
        selected_entry = null;
        select_entry (saved_entry, 1, start_scrolling);
        move_names ();
    }

    private void allocate_greeter_box ()
    {
        Gtk.Allocation allocation;
        //get_allocation (out allocation);
        selected_entry.small_user_face_image.get_allocation (out allocation);
        //selected_entry.get_allocation (out allocation);
        var child_allocation = Gtk.Allocation ();
        //greeter_box.get_preferred_width (null, out child_allocation.width);
        //greeter_box.get_preferred_height (null, out child_allocation.height);
       if(status==Status.LOGINBOX||status==Status.SESSIONLIST)
            child_allocation.width = grid_size * LOGINBOX_WIDTH - BORDER * 2;
        else
            child_allocation.width = allocation.width + BORDER * 4;//grid_size * BOX_WIDTH - BORDER * 2;
        //selected_entry.small_user_face_image.get_preferred_width (child_allocation.width, null, out child_allocation.height);
        child_allocation.height = allocation.height + BORDER * 4;
        child_allocation.x = allocation.x - BORDER * 2;// + get_greeter_box_x ();
        child_allocation.y = allocation.y - BORDER * 2;// + get_greeter_box_y ();
        fixed.move (greeter_box, child_allocation.x, child_allocation.y);
        greeter_box.size_allocate (child_allocation);
        /*
        foreach (var entry in entries)
        {
            entry.set_zone (greeter_box);
        }*/
    }

    public override void size_allocate (Gtk.Allocation allocation)
    {
        base.size_allocate (allocation);

        if (!get_realized ())
            return;
        move_names ();
        allocate_greeter_box ();
        
    }

    public override bool draw (Cairo.Context c)
    {
        c.push_group ();
        if(status==Status.USERLIST)
        {
            c.save ();
            fixed.propagate_draw (greeter_box, c); /* Always full alpha */
            c.restore ();
        }
        
        if (greeter_box.base_alpha != 0.0)
        {
            c.save ();
            c.push_group ();

            //c.rectangle (get_greeter_box_x (), get_greeter_box_y () - n_above * grid_size, grid_size * BOX_WIDTH * n_above  - BORDER * 2, grid_size * n_above *2 );
            //c.clip ();

            foreach (var child in fixed.get_children ())
            {
                if (child != greeter_box)
                    fixed.propagate_draw (child, c);
            }

            c.pop_group_to_source ();
            c.paint_with_alpha (greeter_box.base_alpha);
            c.restore ();
        }

        c.pop_group_to_source ();
        c.paint_with_alpha (fade_tracker.alpha);

        return false;
    }
    
    public void entry_enter_cb ()
    {
          entry_clicked_cb(selected_entry);
    }
    
    private void entry_clicked_cb (PromptBox entry)
    {debug("~~~~~~~~~entry_clicked_cb,status=%d,selected_entry=%s,entry=%s",status,selected_entry.id,entry.id);
        if (mode != Mode.ENTRY)
            return;
        if(status==status_box)
            return;
        status = status_box;
        clicked_location=entries.index (entry);
        move_names ();
        //fixed.move (entry, 0, 0);
        //entry.size_allocate (allocation);
        //entry.show_prompts();
        //if (selected_entry != entry)
        if(status!=Status.SESSIONLIST)
        {
            debug("~~~~~~~~~selected_entry != entry");
            greeter_box.set_base (null);
            if (selected_entry != null)
                selected_entry.clear ();

            selected_entry = entry;
            entry_selected (selected_entry.id);
            setup_prompt_box ();
            
        }
        
        //var index = entries.index (entry);
        //var position = index - scroll_location;
        //debug("~~~~~~~~~~~clicked %d",index);
        /*
        if (position < 0.0)
            select_entry (entry, -1.0);
        else if (position >= 1.0)
            select_entry (entry, 1.0);*/
    }

    public void back_userlist_cb ()
    {
        if(status==Status.LOGINBOX)
        {
            debug("~~~~~~~~back_userlist_cb");
            status=Status.USERLIST;
            
            move_names ();
            selected_entry.hide_prompts();
        }else if(status==Status.SESSIONLIST)
        {debug("~~~~~~~~back_userlist_cb,back_loginbox");
            UnityGreeter.singleton.pop_list();
        }
    }
    
    /* Not all subclasses are going to be interested in talking to lightdm, but for those that are, make it easy. */

    protected bool will_clear = false;
    protected bool prompted = false;
    protected bool unacknowledged_messages = false;

    protected void connect_to_lightdm ()
    {
        UnityGreeter.singleton.show_prompt.connect (show_prompt_cb);
        UnityGreeter.singleton.show_message.connect (show_message_cb);
        
        UnityGreeter.singleton.authentication_complete.connect (authentication_complete_cb);
    }

    protected void show_message_cb (string text, LightDM.MessageType type)
    {
        unacknowledged_messages = true;
        show_message (text, type == LightDM.MessageType.ERROR);
    }

    protected virtual void show_prompt_cb (string text, LightDM.PromptType type)
    {
        /* Notify the greeter on what user has been logged */
        if (get_selected_id () == "*other" && manual_name == null)
        {
            if (UnityGreeter.singleton.test_mode)
                manual_name = test_username;
            else
                manual_name = UnityGreeter.singleton.authentication_user();
        }

        prompted = true;
        if (text == "Password: ")
            text = _("Password:");
        if (text == "login:")
            text = _("Username:");
        add_prompt (text, type == LightDM.PromptType.SECRET);
    }

    protected virtual void authentication_complete_cb ()
    {
        /* Not the best of the solutions but seems the asynchrony
         * when talking to lightdm process means that you can
         * go to the "Guest" account, start authenticating as guest
         * keep moving down to some of the remote servers
         * and the answer will come after that, and even calling
         * greeter.cancel_authentication won't help
         * so basically i'm just ignoring any authentication callback
         * if we are not in the same place in the list as we were
         * when we called greeter.authenticate* */
        if (greeter_authenticating_user != selected_entry.id)
            return;

        bool is_authenticated;
        if (UnityGreeter.singleton.test_mode)
            is_authenticated = test_is_authenticated;
        else
            is_authenticated = UnityGreeter.singleton.is_authenticated();

        if (is_authenticated)
        {
            /* Login immediately if prompted and user has acknowledged all messages */
            if (prompted && !unacknowledged_messages)
            {
                login_complete ();
                if (UnityGreeter.singleton.test_mode)
                    start_session ();
                else
                {
                    if (background.alpha == 1.0)
                        start_session ();
                    else
                        background.notify["alpha"].connect (background_loaded_cb);
                }
            }
            else
            {
                prompted = true;
                show_authenticated ();
            }
        }
        else
        {
            if (prompted)
            {
                /* Show an error if one wasn't provided */
                if (will_clear)
                    show_message (_("Invalid password, please try again"), true);

                selected_entry.reset_spinners ();

                /* Restart authentication */
                start_authentication ();
            }
            else
            {
                /* Show an error if one wasn't provided */
                if (!selected_entry.has_errors)
                    show_message (_("Failed to authenticate"), true);

                /* Stop authentication */
                show_authenticated (false);
            }
        }
    }

    protected virtual void start_authentication ()
    {
        prompted = false;
        unacknowledged_messages = false;

        /* Reset manual username */
        manual_name = null;

        will_clear = false;

        greeter_authenticating_user = get_selected_id ();

        if (UnityGreeter.singleton.test_mode)
            test_start_authentication ();
        else
        {
            if (get_selected_id () == "*other")
                UnityGreeter.singleton.authenticate ();
            else if (get_selected_id () == "*guest")
                UnityGreeter.singleton.authenticate_as_guest ();
            else
                UnityGreeter.singleton.authenticate (get_selected_id ());
        }
    }

    private void background_loaded_cb (ParamSpec pspec)
    {
        if (background.alpha == 1.0)
        {
            background.notify["alpha"].disconnect (background_loaded_cb);
            start_session ();
        }
    }

    private void start_session ()
    {
        if (!UnityGreeter.singleton.start_session (get_lightdm_session (), background))
        {
            show_message (_("Failed to start session"), true);
            start_authentication ();
            return;
        }

        /* Set the background */
        background.draw_grid = false;
        background.queue_draw ();
    }

    public void login_complete ()
    {
        sensitive = false;

        selected_entry.clear ();
        selected_entry.add_message (_("Logging in…"), false);

        redraw_greeter_box ();
    }

    protected virtual string get_lightdm_session ()
    {
        return "ubuntu";
    }

    /* Testing code below this */

    protected string? test_username = null;
    protected bool test_is_authenticated = false;

    protected virtual void test_start_authentication ()
    {
    }
}
