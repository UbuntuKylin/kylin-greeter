/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2011,2012 Canonical Ltd
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
 */

public class MainWindow : Gtk.Window
{
   //public MenuBar menubar;

    private List<Monitor> monitors;
    private Monitor? primary_monitor;
    private Monitor active_monitor;
    private Background background;
    private Gtk.Box login_box;
    private Gtk.Box hbox;
    private Gtk.Button back_button;
    private ShutdownDialog? shutdown_dialog = null;

    public ListStack stack;

    private UserList greeter_list;
    
	public Gtk.Window? keyboard_window { get; private set; default = null; }
	private Pid keyboard_pid = 0;
	private Gtk.Button shutdownbutton;
	private Gtk.ToggleButton a11ybutton;
    // Menubar is smaller, but with shadow, we reserve more space
    public static const int BUTTONBOX_HEIGHT = 80;

    construct
    {
        events |= Gdk.EventMask.POINTER_MOTION_MASK;

        var accel_group = new Gtk.AccelGroup ();
        add_accel_group (accel_group);

        var bg_color = Gdk.RGBA ();
        bg_color.parse (UGSettings.get_string (UGSettings.KEY_BACKGROUND_COLOR));
        override_background_color (Gtk.StateFlags.NORMAL, bg_color);
        get_accessible ().set_name (_("Login Screen"));
        has_resize_grip = false;
        UnityGreeter.add_style_class (this);

        realize ();
        background = new Background (Gdk.cairo_create (get_window ()).get_target ());
        background.draw_grid = UGSettings.get_boolean (UGSettings.KEY_DRAW_GRID);
        background.default_background = UGSettings.get_string (UGSettings.KEY_BACKGROUND);
        background.set_logo (UGSettings.get_string (UGSettings.KEY_LOGO), UGSettings.get_string (UGSettings.KEY_BACKGROUND_LOGO));
        background.show ();
        add (background);
        UnityGreeter.add_style_class (background);

        login_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        login_box.show ();
        background.add (login_box);

        /* 删除原有菜单栏及其中的indicator，新增两个按钮 作为代替*/
      //  var buttonbox = new Gtk.EventBox ();
        var buttonbox =new Gtk.HButtonBox ();
       
        buttonbox.set_layout (Gtk.ButtonBoxStyle.END);
        buttonbox.set_spacing(-1);
        var shadow_style = "";
        try
        {
            var style = new Gtk.CssProvider ();
            style.load_from_data ("* {background-color: transparent;
                                      %s
                                     }".printf(shadow_style), -1);
            var context = buttonbox.get_style_context ();
            context.add_provider (style,
                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
        catch (Error e)
        {
            debug ("Internal error loading buttonbox style: %s", e.message);
        }
        buttonbox.set_size_request (-1,BUTTONBOX_HEIGHT);
        buttonbox.show ();
       var buttonbox_align = new Gtk.Alignment (1.0f,1.0f, 0.0f, 0.0f);
       buttonbox_align.show();
       
        login_box.add (buttonbox_align);
       buttonbox_align.add(buttonbox);
        UnityGreeter.add_style_class (buttonbox);
        
         //TOFIX：menubar已经不需要
       // menubar = new MenuBar (background, accel_group);
		
        
        //a11y按钮
        var a11yalign = new Gtk.Alignment (1.0f,1.0f, 0.0f, 0.0f);
        a11yalign.show();
        buttonbox.add(a11yalign);
        a11ybutton = new Gtk.ToggleButton ();
        a11ybutton.focus_on_click = false;
        a11ybutton.can_focus = false;
		a11ybutton.show();
		var a11ybuttonimage = new Gtk.Image.from_file (Path.build_filename (Config.PKGDATADIR, "keyboardbutton.png"));
        a11ybuttonimage.show ();
        a11ybutton.add (a11ybuttonimage);
        a11ybutton.toggled.connect (keyboardbutton_clicked_cb);
        a11yalign.add (a11ybutton);
        UnityGreeter.add_style_class (a11ybutton);
        
        
        //关机按钮
		var shutdownbutton_align = new Gtk.Alignment (0.5f, 1.0f, 0.0f,0.0f);
        shutdownbutton_align.show ();
        buttonbox.add (shutdownbutton_align);
        UnityGreeter.add_style_class (shutdownbutton_align);
		shutdownbutton = new Gtk.Button ();
		shutdownbutton.show();
        shutdownbutton.focus_on_click = false;
        shutdownbutton.can_focus = false;
		var shutdownbutton_image = new Gtk.Image.from_file (Path.build_filename (Config.PKGDATADIR,"shutdownbutton.png"));
        shutdownbutton_image.show ();
        shutdownbutton.add (shutdownbutton_image);
        shutdownbutton.clicked.connect (shutdownbutton_clicked_cb);
        shutdownbutton_align.add (shutdownbutton);
        
       
        UnityGreeter.add_style_class (shutdownbutton);

       
        hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        hbox.expand = true;
        hbox.show ();
        login_box.add (hbox);

        //var align = new Gtk.Alignment (0.5f, 0.5f, 0.0f, 0.0f);
        //align.set_size_request (grid_size, -1);
        //align.margin_bottom = BUTTONBOX_HEIGHT; /* offset for BUTTONBOX at top */
        //align.show ();
        //hbox.add (align);

        /*
        back_button = new FlatButton ();
        back_button.get_accessible ().set_name (_("Back"));
        back_button.focus_on_click = false;
        var image = new Gtk.Image.from_file (Path.build_filename (Config.PKGDATADIR, "arrow_left.png", null));
        image.show ();
        back_button.set_size_request (grid_size - GreeterList.BORDER * 2, grid_size - GreeterList.BORDER * 2);
        back_button.add (image);
        back_button.clicked.connect (pop_list);
        align.add (back_button);
        */
        var align = new Gtk.Alignment (0.0f, 0.0f, 0.0f, 0.0f);//用户列表的位置
        //align.margin_bottom = BUTTONBOX_HEIGHT; /* offset for BUTTONBOX at top */
        align.show ();
        hbox.add (align);

        stack = new ListStack ();
        stack.show ();
        align.add (stack);

        add_user_list ();

        if (UnityGreeter.singleton.test_mode)
        {
            /* Simulate an 800x600 monitor to the left of a 640x480 monitor */
            monitors = new List<Monitor> ();
            monitors.append (new Monitor (0, 0, 800, 600));
            monitors.append (new Monitor (800, 120, 640, 480));
            background.set_monitors (monitors);
            move_to_monitor (monitors.nth_data (0));
            resize (800 + 640, 600);
        }
        else
        {
            var screen = get_screen ();
            screen.monitors_changed.connect (monitors_changed_cb);
            monitors_changed_cb (screen);
        }
    }

    public void push_list (GreeterList widget)
    {
        stack.push (widget);

        if (stack.num_children > 1)
            back_button.show ();
    }

    public void pop_list ()
    {
        if (stack.num_children <= 2)
            back_button.hide ();

        stack.pop ();
    }

    public override void size_allocate (Gtk.Allocation allocation)
    {
        base.size_allocate (allocation);

        /*if (hbox != null)
        {//用户列表框进行偏移
            hbox.margin_left = get_grid_offset (get_allocated_width ());// + grid_size;
            hbox.margin_right = get_grid_offset (get_allocated_width ());
            hbox.margin_top = get_grid_offset (get_allocated_height ());
            hbox.margin_bottom = get_grid_offset (get_allocated_height ());
        }*/
    }

	private void shutdownbutton_clicked_cb (Gtk.Button button)
    {
      debug ("shutdownbutton_clicked~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
			
			show_shutdown_dialog (ShutdownDialogType.SHUTDOWN);
    }
    
    private void keyboardbutton_clicked_cb (Gtk.ToggleButton button)
    {
       UGSettings.set_boolean (UGSettings.KEY_ONSCREEN_KEYBOARD, button.active);

        if (keyboard_window == null)
        {
            int id = 0;

            try
            {
                string[] argv;
                int onboard_stdout_fd;

                Shell.parse_argv ("onboard --xid", out argv);
                Process.spawn_async_with_pipes (null,
                                                argv,
                                                null,
                                                SpawnFlags.SEARCH_PATH,
                                                null,
                                                out keyboard_pid,
                                                null,
                                                out onboard_stdout_fd,
                                                null);
                var f = FileStream.fdopen (onboard_stdout_fd, "r");
                var stdout_text = new char[1024];
                if (f.gets (stdout_text) != null)
                    id = int.parse ((string) stdout_text);

            }
            catch (Error e)
            {
                warning ("Error setting up keyboard: %s", e.message);
                return;
            }

            var keyboard_socket = new Gtk.Socket ();
            keyboard_socket.show ();
            keyboard_window = new Gtk.Window ();
            keyboard_window.accept_focus = false;
            keyboard_window.focus_on_map = false;
            keyboard_window.add (keyboard_socket);
            keyboard_socket.add_id (id);

            /* Put keyboard at the bottom of the screen */
            var screen = get_screen ();
            var monitor = screen.get_monitor_at_window (get_window ());
            Gdk.Rectangle geom;
            screen.get_monitor_geometry (monitor, out geom);
            keyboard_window.move (geom.x, geom.y + geom.height - 200);
            keyboard_window.resize (geom.width, 200);
        }

        keyboard_window.visible = button.active;
    }
    
    private void monitors_changed_cb (Gdk.Screen screen)
    {
        int primary = screen.get_primary_monitor ();
        debug ("Screen is %dx%d pixels", screen.get_width (), screen.get_height ());
        monitors = new List<Monitor> ();
        primary_monitor = null;

        for (var i = 0; i < screen.get_n_monitors (); i++)
        {
            Gdk.Rectangle geometry;
            screen.get_monitor_geometry (i, out geometry);
            debug ("Monitor %d is %dx%d pixels at %d,%d", i, geometry.width, geometry.height, geometry.x, geometry.y);

            if (monitor_is_unique_position (screen, i))
            {
                var monitor = new Monitor (geometry.x, geometry.y, geometry.width, geometry.height);
                monitors.append (monitor);

                if (primary_monitor == null || i == primary)
                    primary_monitor = monitor;
            }
        }

        background.set_monitors (monitors);
        resize (screen.get_width (), screen.get_height ());
        move (0, 0);
        move_to_monitor (primary_monitor);
        
    }

    /* Check if a monitor has a unique position */
    private bool monitor_is_unique_position (Gdk.Screen screen, int n)
    {
        Gdk.Rectangle g0;
        screen.get_monitor_geometry (n, out g0);

        for (var i = n + 1; i < screen.get_n_monitors (); i++)
        {
            Gdk.Rectangle g1;
            screen.get_monitor_geometry (i, out g1);

            if (g0.x == g1.x && g0.y == g1.y)
                return false;
        }

        return true;
    }

    public override bool motion_notify_event (Gdk.EventMotion event)
    {
        var x = (int) (event.x + 0.5);
        var y = (int) (event.y + 0.5);

        /* Get motion event relative to this widget */
        if (event.window != get_window ())
        {
            int w_x, w_y;
            get_window ().get_origin (out w_x, out w_y);
            x -= w_x;
            y -= w_y;
            event.window.get_origin (out w_x, out w_y);
            x += w_x;
            y += w_y;
        }

        foreach (var m in monitors)
        {
            if (x >= m.x && x <= m.x + m.width && y >= m.y && y <= m.y + m.height)
            {
                move_to_monitor (m);
                stack.queue_resize ();
                break;
            }
        }

        return false;
    }

    private void move_to_monitor (Monitor monitor)
    {
        active_monitor = monitor;
        login_box.set_size_request (monitor.width, monitor.height);
        stack.set_size(monitor.width,monitor.height-BUTTONBOX_HEIGHT);
       
        background.set_active_monitor (monitor);
        background.move (login_box, monitor.x, monitor.y);

        if (shutdown_dialog != null)
        {
            shutdown_dialog.set_active_monitor (monitor);
            background.move (shutdown_dialog, monitor.x, monitor.y);
        }
    }

    private void add_user_list ()
    {
        
        greeter_list = new UserList (background);
        greeter_list.show ();
        UnityGreeter.add_style_class (greeter_list);
        //greeter_list.back_loginbox.connect(pop_list);
        push_list (greeter_list);
    }

    public override bool key_press_event (Gdk.EventKey event)
    {
        var top = stack.top ();

        if (stack.top () is UserList)
        {
            var user_list = stack.top () as UserList;
            if (!user_list.show_hidden_users)
            {
                var shift_mask = Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.MOD1_MASK;
                var control_mask = Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.MOD1_MASK;
                var alt_mask = Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK;
                if (((event.keyval == Gdk.Key.Shift_L || event.keyval == Gdk.Key.Shift_R) && (event.state & shift_mask) == shift_mask) ||
                    ((event.keyval == Gdk.Key.Control_L || event.keyval == Gdk.Key.Control_R) && (event.state & control_mask) == control_mask) ||
                    ((event.keyval == Gdk.Key.Alt_L || event.keyval == Gdk.Key.Alt_R) && (event.state & alt_mask) == alt_mask))
                {
                    debug ("Hidden user key combination detected");
                    user_list.show_hidden_users = true;
                    return true;
                }
            }
        }

        switch (event.keyval)
        {
        case Gdk.Key.Escape:
            if (login_box.sensitive && top.status!=GreeterList.Status.USERLIST)
            {
                top.cancel_authentication ();
                top.back_userlist_cb();
            }
            if (shutdown_dialog != null)
                shutdown_dialog.cancel ();
            return true;
        case Gdk.Key.Page_Up:
        case Gdk.Key.KP_Page_Up:
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.START);
                return true;
            }
            break;
        case Gdk.Key.Page_Down:
        case Gdk.Key.KP_Page_Down:
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.END);
                return true;
            }
            break;
        case Gdk.Key.Up:
        case Gdk.Key.KP_Up:
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.UP);
                return true;
            }
            break;
        case Gdk.Key.Down:
        case Gdk.Key.KP_Down:
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.DOWN);
                return true;
            }
            break;
        case Gdk.Key.Left:
        case Gdk.Key.KP_Left:
            if (shutdown_dialog != null)
                shutdown_dialog.focus_prev ();
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.LEFT);
                return true;
            }
            break;
        case Gdk.Key.Right:
        case Gdk.Key.KP_Right:
            if (shutdown_dialog != null)
                shutdown_dialog.focus_next ();
            if (login_box.sensitive && top.status==GreeterList.Status.USERLIST)
            {
                top.scroll (GreeterList.ScrollTarget.RIGHT);
                return true;
            }
            break;
        case Gdk.Key.F10:
           if (login_box.sensitive)
                show_shutdown_dialog (ShutdownDialogType.SHUTDOWN);
            return true;
        case Gdk.Key.Return:
        case Gdk.Key. KP_Enter:
           if (top.status==GreeterList.Status.USERLIST)
            {
                greeter_list.entry_enter_cb();
                return true;
            }
            break;
        case Gdk.Key.PowerOff:
            show_shutdown_dialog (ShutdownDialogType.SHUTDOWN);
            return true;
        case Gdk.Key.z:
            if (UnityGreeter.singleton.test_mode && (event.state & Gdk.ModifierType.MOD1_MASK) != 0)
            {
                show_shutdown_dialog (ShutdownDialogType.SHUTDOWN);
                return true;
            }
            break;
       
        }

        return base.key_press_event (event);
    }

    public void set_keyboard_state ()
    {
		debug ("~~~~~~~~~set_keyboard_state~~~~~~~~~~");
        a11ybutton.set_active (UGSettings.get_boolean (UGSettings.KEY_ONSCREEN_KEYBOARD));
    }

    public void show_shutdown_dialog (ShutdownDialogType type)
    {
        if (shutdown_dialog != null)
            shutdown_dialog.destroy ();

        /* Stop input to login box */
        login_box.sensitive = false;

        shutdown_dialog = new ShutdownDialog (type, background);
        shutdown_dialog.closed.connect (close_shutdown_dialog);
        background.add (shutdown_dialog);
        move_to_monitor (active_monitor);
        shutdown_dialog.visible = true;
    }

    public void close_shutdown_dialog ()
    {
        if (shutdown_dialog == null)
            return;

        shutdown_dialog.destroy ();
        shutdown_dialog = null;

        login_box.sensitive = true;
    }
}
