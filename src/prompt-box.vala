/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2011,2012 Canonical Ltd
 *               2015, National University of Defense Technology(NUDT) & Kylin Ltd
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
 * Modified by : zhangchao <zhangchao@ubuntukylin.com>
 */

public class PromptBox : FadableBox
{
    public signal void respond (string[] response);
    public signal void login ();
    public signal void show_options (string face_image);
    public signal void name_clicked ();
    public signal void back_userlist();
    
    public bool has_errors { get; set; default = false; }
    public string id { get; construct; }

    public string label
    {
        get { return name_label.label; }
        set
        {
            name_label.label = value;
            small_name_label.label = value;
        }
    }

    public double position { get; set; default = 0; }

    private Gtk.Fixed fixed;
    private Gtk.Widget zone; /* when overlapping zone we are fully expanded */

    /* Expanded widgets */
    protected Gtk.Grid box_grid;
    protected Gtk.Grid name_grid;

    private ActiveLabel small_active_label;
    protected FadingLabel name_label;
    private ActiveLabel active_label;
    protected FlatButton option_button;
    private CachedImage option_image;
    private CachedImage message_image;

    /* Condensed widgets */
    protected Gtk.Widget small_box_widget;

    protected FadingLabel small_name_label;


    private GreeterButton back_button;
    //user face by pz
    private Gtk.Image tmp_face_image;
    private CachedImage user_face_image;
    public CachedImage small_user_face_image;
    public string face;
    private string face_path;
    private string logined_string=_("Logined");
    protected static const int COL_BACKBUTTON    = 0;
    protected static const int COL_ACTIVE        = 1;
    protected static const int COL_CONTENT       = 2;
    //protected static const int COL_SPACER        = 2;

    protected static const int ROW_NAME          = 0;
    protected static const int COL_NAME_LABEL    = 0;
    protected static const int COL_NAME_MESSAGE  = 1;
    protected static const int COL_NAME_OPTIONS  = 2;

    protected static const int COL_ENTRIES_START = 2;
    protected static const int COL_ENTRIES_END   = 2;
    protected static const int COL_ENTRIES_WIDTH = 1;

    protected static  string back_button_normal = Path.build_filename (Config.PKGDATADIR, "arrow_left.png", null);
    protected static  string back_button_prelight = Path.build_filename (Config.PKGDATADIR, "arrow_left_prelight.png", null);
    protected static  string back_button_active = Path.build_filename (Config.PKGDATADIR, "arrow_left_active.png", null);
    protected int start_row;
    protected int last_row;

    private enum PromptVisibility
    {
        HIDDEN,
        FADING,
        SHOWN,
    }
    private PromptVisibility prompt_visibility = PromptVisibility.HIDDEN;

    public PromptBox (string id)
    {
        Object (id: id);
    }

    construct
    {
        // Hack to avoid gtk 3.20's new allocate logic, which messes us up.
        resize_mode = Gtk.ResizeMode.QUEUE;

        set_start_row ();
        reset_last_row ();
        expand = true;

        fixed = new Gtk.Fixed ();
        fixed.show ();
        add (fixed);

        box_grid = new Gtk.Grid ();
        box_grid.column_spacing = 20;
        box_grid.row_spacing = 3;
        box_grid.margin_top = GreeterList.BORDER;
        box_grid.margin_bottom = 6;
        box_grid.expand = true;
        
        
        box_grid.show ();

        //add back_button

        back_button = new GreeterButton ();
        UnityGreeter.add_style_class(back_button);

        back_button.set_status_images(back_button_normal,back_button_prelight,back_button_active);
        Gtk.button_set_focus_on_click (back_button, false);
        back_button.can_focus = false;
        back_button.yalign=0.5f;
        var image = new Gtk.Image.from_file (back_button_normal);
        back_button.set_image (image);
        back_button.set_always_show_image(true);
        back_button.clicked.connect (back_cb);
        back_button.show();

        var back_button_align = new Gtk.Alignment (0.5f, 0.0f, 0.0f, 0.0f);
        back_button_align.add (back_button);
        back_button_align.show();
        box_grid.attach (back_button_align, COL_BACKBUTTON, 0, 1, 1);
        
        //add user face by pz
        user_face_image = new CachedImage(null);
        user_face_image.draw_white_border();
        tmp_face_image = new CachedImage(null);
         try
        {
            
                user_face_image.pixbuf = new Gdk.Pixbuf.from_file (Path.build_filename (Config.PKGDATADIR, "default_face.png", null));
        }
        catch (Error e)
        {
            debug ("Error loading user default face image: %s", e.message);
        }
        
        user_face_image.show();
        var user_face_align = new Gtk.Alignment (0.0f, 0.0f, 0.0f, 0.0f);
        user_face_align.add (user_face_image);
        user_face_align.show ();
        box_grid.attach (user_face_align, COL_ACTIVE, 0, 1, 5);
        
        /* Create fully expanded version of ourselves */
        name_grid = create_name_grid ();
        box_grid.attach (name_grid, COL_CONTENT, 0, 1, 1);

        
        /* Now prep small versions of the above normal widgets.  These are
         * used when scrolling outside of the main dash box. */
        var small_box_grid = new Gtk.Grid ();
        small_box_grid.column_spacing = 4;
        small_box_grid.row_spacing = 16;
        small_box_grid.hexpand = true;
        small_box_grid.show ();
        //by pz
        small_user_face_image = new CachedImage(null);
        small_user_face_image.draw_white_border();
        small_user_face_image.pixbuf=scale(user_face_image.pixbuf,96,96);
        small_user_face_image.show();
        var small_user_face_align = new Gtk.Alignment (0.5f, 0.5f, 0.0f, 0.0f);
        small_user_face_align.add (small_user_face_image);
        small_user_face_align.show ();
        small_box_grid.attach(small_user_face_align,0,0,1,1);

        
        var small_name_grid = create_small_name_grid ();
        small_box_grid.attach (small_name_grid, 0, 1, 1, 1);

        var small_box_eventbox = new Gtk.EventBox ();
        small_box_eventbox.visible_window = false;
        small_box_eventbox.button_release_event.connect (() =>
        {
            name_clicked ();
            return true;
        });
        small_box_eventbox.add (small_box_grid);
        small_box_eventbox.show ();
        small_box_widget = small_box_eventbox;

        fixed.add (small_box_widget);
        fixed.add (box_grid);
        
    }

    public void back_cb ()
    {
        
        back_userlist();
    }

    public void set_face_size(int size)
    {
        small_user_face_image.pixbuf=scale(tmp_face_image.pixbuf,size,size);
    }
    
    public void set_face_image(string? face)
    {

        face_path = face;
          try
        {
            tmp_face_image.pixbuf = new Gdk.Pixbuf.from_file (Path.build_filename (Path.build_filename (face)));
            
        }
        catch (Error e)
        {
            debug ("Error loading user face image: %s", e.message);
            face_path = Path.build_filename (Config.PKGDATADIR, "default_face.png", null);
            tmp_face_image.set_from_file(face_path);
            
        }
        
        
        user_face_image.pixbuf=scale(tmp_face_image.pixbuf,128,128);
        small_user_face_image.pixbuf=scale(tmp_face_image.pixbuf,128,128);
        //debug("~~~~~~~~set_face_image~~~~~~~~~~");
    }
    private Gdk.Pixbuf? scale (Gdk.Pixbuf? image, int width, int height)
    {
        var target_aspect = (double) width / height;
        var aspect = (double) image.width / image.height;
        double scale, offset_x = 0, offset_y = 0;
        if (aspect > target_aspect)
        {
            /* Fit height and trim sides */
            scale = (double) height / image.height;
            offset_x = (image.width * scale - width) / 2;
        }
        else
        {
            /* Fit width and trim top and bottom */
            scale = (double) width / image.width;
            offset_y = (image.height * scale - height) / 2;
        }

        var scaled_image = new Gdk.Pixbuf (image.colorspace, image.has_alpha, image.bits_per_sample, width, height);
        image.scale (scaled_image, 0, 0, width, height, -offset_x, -offset_y, scale, scale, Gdk.InterpType.BILINEAR);

        return scaled_image;
    }
    protected virtual Gtk.Grid create_name_grid ()
    {
        var name_grid = new Gtk.Grid ();
        name_grid.column_spacing = 4;
        name_grid.hexpand = true;

        name_label = new FadingLabel ("");
        name_label.override_font (Pango.FontDescription.from_string ("Ubuntu 13"));
        name_label.override_color (Gtk.StateFlags.NORMAL, { 1.0f, 1.0f, 1.0f, 1.0f });
        name_label.valign = Gtk.Align.START;
        //name_label.vexpand = true;
        name_label.yalign = 0.0f;
        name_label.xalign = 0.0f;
        name_label.margin_left = 2;
        //name_label.set_size_request (-1, grid_size);
        name_label.show ();
        name_grid.attach (name_label, COL_NAME_LABEL, ROW_NAME, 1, 1);

        message_image = new CachedImage (null);
        try
        {
            message_image.pixbuf = new Gdk.Pixbuf.from_file (Path.build_filename (Config.PKGDATADIR, "message.png", null));
        }
        catch (Error e)
        {
            debug ("Error loading message image: %s", e.message);
        }

        var align = new Gtk.Alignment (0.5f, 0.0f, 0.0f, 0.0f);
        align.valign = Gtk.Align.START;
        //align.set_size_request (-1, grid_size);
        align.add (message_image);
        align.show ();
        name_grid.attach (align, COL_NAME_MESSAGE, ROW_NAME, 1, 1);

        option_button = new FlatButton ();
        option_button.hexpand = true;
        option_button.halign = Gtk.Align.END;
        option_button.valign = Gtk.Align.START;
        // Keep as much space on top as on the right
        //option_button.margin_top = ActiveIndicator.WIDTH + box_grid.column_spacing;
        Gtk.button_set_focus_on_click (option_button, false);
        option_button.relief = Gtk.ReliefStyle.NONE;
        option_button.get_accessible ().set_name (_("Session Options"));
        option_button.clicked.connect (option_button_clicked_cb);
        option_image = new CachedImage (null);
        option_image.show ();
        try
        {
            var style = new Gtk.CssProvider ();
            style.load_from_data ("* {padding: 2px;}", -1);
            option_button.get_style_context ().add_provider (style, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
        catch (Error e)
        {
            debug ("Internal error loading session chooser style: %s", e.message);
        }
        option_button.add (option_image);
        name_grid.attach (option_button, COL_NAME_OPTIONS, ROW_NAME, 1, 1);

        active_label = new ActiveLabel(logined_string);
        active_label.yalign = 0.0f;
        active_label.xalign = 0.0f;
        active_label.vexpand = true;
        active_label.margin_left = 2;
        active_label.show();
        name_grid.attach (active_label, 0, 1, 1, 1);
        
        name_grid.show ();

        return name_grid;
    }

    protected virtual Gtk.Grid create_small_name_grid ()
    {
        var small_name_grid = new Gtk.Grid ();
        small_name_grid.row_spacing = 4;
        small_name_grid.hexpand=true;
        small_name_label = new FadingLabel ("");
        small_name_label.override_font (Pango.FontDescription.from_string ("Ubuntu 10"));
        small_name_label.override_color (Gtk.StateFlags.NORMAL, { 1.0f, 1.0f, 1.0f, 1.0f });
        small_name_label.yalign = 0.5f;
        small_name_label.xalign = 0.5f;
        small_name_label.hexpand=true;

        small_name_label.set_size_request (grid_size, -1);
        small_name_label.show ();
        small_name_grid.attach (small_name_label, 0, 2, 1, 1);

        small_active_label = new ActiveLabel(logined_string);
        small_active_label.show();
        small_name_grid.attach (small_active_label, 0, 3, 1, 1);
        
        
        small_name_grid.show ();
        return small_name_grid;
    }

    protected virtual void set_start_row ()
    {
        start_row = 0;
    }

    protected virtual void reset_last_row ()
    {
        last_row = start_row;
    }

    public override void get_preferred_height (out int min, out int nat)
    {
        if(prompt_visibility==PromptVisibility.SHOWN)
        {
            box_grid.get_preferred_height (out min, out nat);
        }else{
            small_box_widget.get_preferred_height (out min, out nat);
        }
    }

    public void set_zone (Gtk.Widget zone)
    {
        this.zone = zone;
        queue_draw ();
    }

    public void set_name_color_red()
    {
        small_name_label.override_color(Gtk.StateFlags.NORMAL, { 1.0f, 0.0f, 0.0f, 1.0f });

    }

    public void set_name_color_default()
    {
        small_name_label.override_color(Gtk.StateFlags.NORMAL, { 1.0f, 1.0f, 1.0f, 1.0f });

    }
    
    public void set_options_image (Gdk.Pixbuf? image)
    {
        if (option_button == null)
            return;

        option_image.pixbuf = image;

        if (image == null)
            option_button.hide ();
        else
            option_button.show ();
    }

    private void option_button_clicked_cb (Gtk.Button button)
    {
        show_options (face_path);
    }

    public void set_show_message_icon (bool show)
    {
        message_image.visible = show;
    }

    public void set_is_active (bool active)
    {
        small_active_label.active = active;
        active_label.active = active;
        
    }

    protected void foreach_prompt_widget (Gtk.Callback cb)
    {
        var prompt_widgets = new List<Gtk.Widget> ();

        var i = start_row + 1;
        while (i <= last_row)
        {
            var c = box_grid.get_child_at (COL_ENTRIES_START, i);
            if (c != null) /* c might have been deleted from selective clear */
                prompt_widgets.append (c);
            i++;
        }

        foreach (var w in prompt_widgets)
            cb (w);
    }

    public void clear ()
    {
        prompt_visibility = PromptVisibility.HIDDEN;
        foreach_prompt_widget ((w) => { w.destroy (); });
        reset_last_row ();
        has_errors = false;
    }

    /* Clears error messages */
    public void reset_messages ()
    {
        has_errors = false;
        foreach_prompt_widget ((w) =>
        {
            var is_error = w.get_data<bool> ("prompt-box-is-error");
            if (is_error)
                w.destroy ();
        });
    }

    /* Stops spinners */
    public void reset_spinners ()
    {
        foreach_prompt_widget ((w) =>
        {
            if (w is DashEntry)
            {
                var e = w as DashEntry;
                e.did_respond = false;
            }
        });
    }

    /* Clears error messages and stops spinners.  Basically gets the box back to a filled-by-user-but-no-status state. */
    public void reset_state ()
    {
        reset_messages ();
        reset_spinners ();
    }

    public virtual void add_static_prompts ()
    {
        /* Subclasses may want to add prompts that are always present here */
    }

    private void update_prompt_visibility (Gtk.Widget w)
    {
        switch (prompt_visibility)
        {
        case PromptVisibility.HIDDEN:
            w.hide ();
            break;
        case PromptVisibility.FADING:
            var f = w as Fadable;
            w.sensitive = true;
            if (f != null)
                f.fade_in ();
            else
                w.show ();
            break;
        case PromptVisibility.SHOWN:
            w.show ();
            w.sensitive = true;
            break;
        }
    }

    public void fade_in_prompts ()
    {
        prompt_visibility = PromptVisibility.FADING;
        show ();
        foreach_prompt_widget ((w) => { update_prompt_visibility (w); });
    }

    public void show_prompts ()
    {
        //debug("~~~~~~~~~~show_prompts = %s",this.id);
        prompt_visibility = PromptVisibility.SHOWN;
        show ();
        foreach_prompt_widget ((w) => { update_prompt_visibility (w); });
    }

        public void hide_prompts ()
    {
        //debug("~~~~~~~~~~hide_prompts = %s",this.id);

        prompt_visibility = PromptVisibility.HIDDEN;
        show ();
    }
    
    protected void attach_item (Gtk.Widget w, bool add_style_class = true , bool is_message = false)
    {   
        w.set_data ("prompt-box-widget", this);
        if (add_style_class)
            UnityGreeter.add_style_class (w);

        last_row += 1;
        
        if(is_message==true)
        {   //debug("!!!!!!!!!!!!!~~~~~~~~~~~~~~~~~~~~~~is_message==true");
            box_grid.attach (w, COL_ENTRIES_START, last_row, COL_ENTRIES_WIDTH, 1);
        }else{
            box_grid.attach (w, COL_ENTRIES_START, last_row, COL_ENTRIES_WIDTH, 1);
        }
        update_prompt_visibility (w);
        queue_resize ();
    }

    public void add_message (string text, bool is_error)
    {
        var label = new FadingLabel (text);

        label.override_font (Pango.FontDescription.from_string ("Ubuntu 10"));

        Gdk.RGBA color = { 1.0f, 1.0f, 1.0f, 1.0f };
        if (is_error)
            color.parse ("#df382c");
        label.override_color (Gtk.StateFlags.NORMAL, color);

        label.xalign = 0.0f;
        label.set_data<bool> ("prompt-box-is-error", is_error);

        if (is_error)
        {
            attach_item (label);
            has_errors = true;
        }else{
            attach_item (label,true,true);
        }
    }

    public DashEntry add_prompt (string text, string? accessible_text, bool is_secret)
    {
        /* Stop other entry's arrows/spinners from showing */
        foreach_prompt_widget ((w) =>
        {
            if (w is DashEntry)
            {
                var e = w as DashEntry;
                if (e != null)
                    e.can_respond = false;
            }
        });

        var entry = new DashEntry ();
        entry.sensitive = false;

        if (text.contains ("\n"))
        {
            add_message (text, false);
            entry.constant_placeholder_text = "";
        }
        else
        {
            /* Strip trailing colon if present (also handle CJK version) */
            var placeholder = text;
            if (placeholder.has_suffix (":") || placeholder.has_suffix ("："))
            {
                var len = placeholder.char_count ();
                placeholder = placeholder.substring (0, placeholder.index_of_nth_char (len - 1));
            }
            entry.constant_placeholder_text = placeholder;
        }

        var accessible = entry.get_accessible ();
        if (accessible_text != null)
            accessible.set_name (accessible_text);
        else
            accessible.set_name (text);

        if (is_secret)
        {
            entry.visibility = false;
            entry.caps_lock_warning = true;
        }

        entry.respond.connect (entry_activate_cb);

        attach_item (entry);

        return entry;
    }

    public Gtk.ComboBox add_combo (GenericArray<string> texts, bool read_only)
    {
        Gtk.ComboBoxText combo;
        if (read_only)
            combo = new Gtk.ComboBoxText ();
        else
            combo = new Gtk.ComboBoxText.with_entry ();

        combo.get_style_context ().add_class ("lightdm-combo");
        combo.get_child ().get_style_context ().add_class ("lightdm-combo");
        combo.get_child ().override_font (Pango.FontDescription.from_string (DashEntry.font));

        attach_item (combo, false);

        texts.foreach ((text) => { combo.append_text (text); });

        if (texts.length > 0)
            combo.active = 0;

        return combo;
    }

    protected void entry_activate_cb ()
    {
        var response = new string[0];

        foreach_prompt_widget ((w) =>
        {
            if (w is Gtk.Entry)
            {
                var e = w as Gtk.Entry;
                if (e != null)
                    response += e.text;
            }
        });
        respond (response);
    }

    public void add_button (string text, string? accessible_text)
    {
        var button = new DashButton (text);

        var accessible = button.get_accessible ();
        accessible.set_name (accessible_text);

        button.clicked.connect (button_clicked_cb);

        attach_item (button);
    }

    private void button_clicked_cb (Gtk.Button button)
    {
        login ();
    }

    public override void grab_focus ()
    {
        var done = false;
        Gtk.Widget best = null;
        foreach_prompt_widget ((w) =>
        {
            if (done)
                return;
            best = w; /* last entry wins, all else considered */
            var e = w as Gtk.Entry;
            var b = w as Gtk.Button;
            var c = w as Gtk.ComboBox;

            /* We've found ideal entry (first empty one), so stop looking */
            if ((e != null && e.text == "") || b != null || c != null)
                done = true;
        });
        if (best != null)
            best.grab_focus ();
    }

    public override void size_allocate (Gtk.Allocation allocation)
    {
        base.size_allocate (allocation);
        box_grid.size_allocate (allocation);
        //debug("~~~~~~~~allocation.x=%d~~allocation.y=%d~~allocation.height=%d~~allocation.width=%d",allocation.x,allocation.y,allocation.height,allocation.width);
        int small_height;
        small_box_widget.get_preferred_height (null, out small_height);
        allocation.height = small_height;
        small_box_widget.size_allocate (allocation);
    }

    public override void draw_full_alpha (Cairo.Context c)
    {
        /* Draw main grid only in that area */
        c.save ();
        if(prompt_visibility==PromptVisibility.SHOWN)
        {
            fixed.propagate_draw (box_grid, c);
            back_button.show();
        }
        else
        {
            fixed.propagate_draw (small_box_widget, c);
            back_button.hide();
        }
        c.restore ();
    }
}

private class ActiveLabel : Gtk.Label
{
    public bool active { get; set; }
    construct
    {
        
        notify["active"].connect (() => { queue_draw (); });
        
    }

    public ActiveLabel (string text)
    {
        Object (label: text);
    }
    
    public override bool draw (Cairo.Context c)
    {
        if (!active)
            return false;
        return base.draw (c);
    }
}

private class ActiveIndicator : Gtk.Image
{
    public bool active { get; set; }
    public static const int WIDTH = 8;
    public static const int HEIGHT = 7;

    construct
    {
        var filename = Path.build_filename (Config.PKGDATADIR, "active.png");
        try
        {
            pixbuf = new Gdk.Pixbuf.from_file (filename);
        }
        catch (Error e)
        {
            debug ("Could not load active image: %s", e.message);
        }
        notify["active"].connect (() => { queue_draw (); });
        xalign = 0.0f;
    }

    public override void get_preferred_width (out int min, out int nat)
    {
        min = WIDTH;
        nat = min;
    }

    public override void get_preferred_height (out int min, out int nat)
    {
        min = HEIGHT;
        nat = min;
    }

    public override bool draw (Cairo.Context c)
    {
        if (!active)
            return false;
        return base.draw (c);
    }
}
public class GreeterButton : Gtk.Button
{
    private Gtk.Image  default_back_image ;
    private Gtk.Image  prelight_back_image;
    private Gtk.Image  active_back_image ;
    
    public void set_status_images(string? normal,string? prelight=null, string? active=null)
    {
        default_back_image = new Gtk.Image.from_file (normal);
        prelight_back_image = new Gtk.Image.from_file (prelight);
        active_back_image = new Gtk.Image.from_file (active);
     
    }
    public override void state_flags_changed (Gtk.StateFlags previous_state)
    {
        var new_flags = get_state_flags ();


        if(new_flags == Gtk.StateFlags.PRELIGHT)
        {
            set_image(prelight_back_image);
        }else if ((new_flags & Gtk.StateFlags.ACTIVE) != 0)
        {
            set_image(active_back_image);
        }else {
            set_image(default_back_image);
        }

        base.state_flags_changed (previous_state);
    }
}
