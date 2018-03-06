/* -*- Mode:Vala; indent-tabs-mode:nil; tab-width:4 -*-
 *
 * Copyright (C) 2011 Canonical Ltd
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
 * Authored by: Michael Terry <michael.terry@canonical.com>
 * Modified by : zhangchao <zhangchao@ubuntukylin.com>
 */

public class SettingsDaemon : Object
{
    private int logind_inhibit_fd = -1;
    private ScreenSaverInterface screen_saver;
    private SessionManagerInterface session_manager;
    private int n_names = 0;

    public void start ()
    {
        string[] disabled = { "org.ukui.SettingsDaemon.plugins.background",
                              "org.ukui.SettingsDaemon.plugins.clipboard",
                              "org.ukui.SettingsDaemon.plugins.font",
                              "org.ukui.SettingsDaemon.plugins.gconf",
                              "org.ukui.SettingsDaemon.plugins.gsdwacom",
                              "org.ukui.SettingsDaemon.plugins.housekeeping",
                              "org.ukui.SettingsDaemon.plugins.keybindings",
                              "org.ukui.SettingsDaemon.plugins.keyboard",
                              "org.ukui.SettingsDaemon.plugins.media-keys",
                              "org.ukui.SettingsDaemon.plugins.mouse",
                              "org.ukui.SettingsDaemon.plugins.print-notifications",
                              "org.ukui.SettingsDaemon.plugins.smartcard",
                              "org.ukui.SettingsDaemon.plugins.sound",
                              "org.ukui.SettingsDaemon.plugins.wacom" };

        string[] enabled =  { "org.ukui.SettingsDaemon.plugins.a11y-keyboard",
                              "org.ukui.SettingsDaemon.plugins.a11y-settings",
                              "org.ukui.SettingsDaemon.plugins.color",
                              "org.ukui.SettingsDaemon.plugins.cursor",
                              "org.ukui.SettingsDaemon.plugins.power",
                              "org.ukui.SettingsDaemon.plugins.xrandr",
                              "org.ukui.SettingsDaemon.plugins.xsettings" };

        foreach (var schema in disabled)
            set_plugin_enabled (schema, false);

        foreach (var schema in enabled)
            set_plugin_enabled (schema, true);

        /* Pretend to be GNOME session */
        session_manager = new SessionManagerInterface ();
        n_names++;
        GLib.Bus.own_name (BusType.SESSION, "org.gnome.SessionManager", BusNameOwnerFlags.NONE,
                           (c) =>
                           {
                               try
                               {
                                   c.register_object ("/org/gnome/SessionManager", session_manager);
                               }
                               catch (Error e)
                               {
                                   warning ("Failed to register /org/gnome/SessionManager: %s", e.message);
                               }
                           },
                           () =>
                           {
                               debug ("Acquired org.gnome.SessionManager");
                               start_settings_daemon ();
                           },
                           () => debug ("Failed to acquire name org.gnome.SessionManager"));

        /* The power plugin does the screen saver screen blanking and disables
         * the builtin X screen saver. It relies on gnome-screensaver to generate
         * the event to trigger this (which actually comes from gnome-session).
         * We implement the gnome-screensaver inteface and start the settings
         * daemon once it is registered on the bus so gnome-screensaver is not
         * started when it accesses this interface */
        screen_saver = new ScreenSaverInterface ();
        n_names++;
        GLib.Bus.own_name (BusType.SESSION, "org.gnome.ScreenSaver", BusNameOwnerFlags.NONE,
                           (c) =>
                           {
                               try
                               {
                                   c.register_object ("/org/gnome/ScreenSaver", screen_saver);
                               }
                               catch (Error e)
                               {
                                   warning ("Failed to register /org/gnome/ScreenSaver: %s", e.message);
                               }
                           },
                           () =>
                           {
                               debug ("Acquired org.gnome.ScreenSaver");
                               start_settings_daemon ();
                           },
                           () => debug ("Failed to acquire name org.gnome.ScreenSaver"));

        /* The media-keys plugin inhibits the power key, but we don't want
           all the other keys doing things. So inhibit it ourselves */
        /* NOTE: We are using the synchronous method here since there is a bug in Vala/GLib in that
         * g_dbus_connection_call_with_unix_fd_list_finish and g_dbus_proxy_call_with_unix_fd_list_finish
         * don't have the GAsyncResult as the second argument.
         * https://bugzilla.gnome.org/show_bug.cgi?id=688907
         */
        try
        {
            var b = Bus.get_sync (BusType.SYSTEM);
            UnixFDList fd_list;
            var result = b.call_with_unix_fd_list_sync  ("org.freedesktop.login1",
                                                         "/org/freedesktop/login1",
                                                         "org.freedesktop.login1.Manager",
                                                         "Inhibit",
                                                         new Variant ("(ssss)",
                                                                      "handle-power-key",
                                                                      Environment.get_user_name (),
                                                                      "Unity Greeter handling keypresses",
                                                                      "block"),
                                                         new VariantType ("(h)"),
                                                         DBusCallFlags.NONE,
                                                         -1,
                                                         null,
                                                         out fd_list);
            int32 index = -1;
            result.get ("(h)", &index);
            logind_inhibit_fd = fd_list.get (index);
        }
        catch (Error e)
        {
            warning ("Failed to inhibit power keys: %s", e.message);
        }
    }

    private void set_plugin_enabled (string schema_name, bool enabled)
    {
        var source = SettingsSchemaSource.get_default ();
        var schema = source.lookup (schema_name, false);
        if (schema != null)
        {
            var settings = new Settings (schema_name);
            settings.set_boolean ("active", enabled);
        }
    }

    private void start_settings_daemon ()
    {
        n_names--;
        if (n_names != 0)
            return;

        debug ("All bus names acquired, starting ukui-settings-daemon");

        try
        {
            Process.spawn_command_line_async (Config.MSD_BINARY);
        }
        catch (SpawnError e)
        {
            debug ("Could not start ukui-settings-daemon: %s", e.message);
        }
    }
}

[DBus (name="org.gnome.ScreenSaver")]
public class ScreenSaverInterface : Object
{
    public signal void active_changed (bool value);

    private Gnome.IdleMonitor idle_monitor;
    private bool _active = false;
    private uint idle_watch = 0;

    public ScreenSaverInterface ()
    {
        idle_monitor = new Gnome.IdleMonitor ();
        _set_active (false);
    }

    private void _set_active (bool value)
    {
        _active = value;
        if (idle_watch != 0)
            idle_monitor.remove_watch (idle_watch);
        idle_watch = 0;
        if (value)
            idle_monitor.add_user_active_watch (() => set_active (false));
        else
        {
            var timeout = UGSettings.get_integer (UGSettings.KEY_IDLE_TIMEOUT);
            if (timeout > 0)
                idle_watch = idle_monitor.add_idle_watch (timeout * 1000, () => set_active (true));
        }
    }

    public void set_active (bool value)
    {
        if (_active == value)
            return;

        if (value)
            debug ("Screensaver activated");
        else
            debug ("Screensaver disabled");

        _set_active (value);
        active_changed (value);
    }

    public bool get_active ()
    {
        return _active;
    }

    public uint32 get_active_time () { return 0; }
    public void lock () {}
    public void show_message (string summary, string body, string icon) {}
    public void simulate_user_activity () {}
}

[DBus (name="org.gnome.SessionManager")]
public class SessionManagerInterface : Object
{
    public bool session_is_active { get { return true; } }
    public string session_name { get { return "ubuntu"; } }
    public uint32 inhibited_actions { get { return 0; } }
}
