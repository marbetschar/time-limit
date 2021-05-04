/*
* Copyright (c) 2021 Marco Betschart (https://marco.betschart.name)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marco Betschart <time-limit@marco.betschart.name
*/

namespace TimeLimit {
    private static bool has_debug;

    const OptionEntry[] OPTIONS = {
        { "debug", 'd', 0, OptionArg.NONE, out has_debug,
        N_("Print debug information"), null},
        { null }
    };

    public class Daemon : GLib.Application {

        private uint timelimit_dbus_service_registration_id = 0;
        private uint alert_timeout = 0;

        private DBusService? timelimit_dbus_service = null;

        construct {
            timelimit_dbus_service = new DBusService ();
            timelimit_dbus_service.notify["alert-datetime-iso8601"].connect (on_timelimit_alert_datetime_changed);

            Bus.own_name (
                BusType.SESSION, "com.github.marbetschar.TimeLimit",
                BusNameOwnerFlags.NONE,
                (connection, name) => {
                    debug ("Aquired DBus connection named '%s'", name);
                    try {
                        timelimit_dbus_service_registration_id = connection.register_object ("/com/github/marbetschar/timelimit", timelimit_dbus_service);
                    } catch (GLib.Error e) {
                        critical ("Error while aquiring DBus connection named '%s': %s", name, e.message);
                    }
                },
                () => {},
                (connection, name) => {
                    if (timelimit_dbus_service_registration_id != 0) {
                        connection.unregister_object (timelimit_dbus_service_registration_id);
                        timelimit_dbus_service_registration_id = 0;

                    }
                    critical ("Could not aquire DBus connection named '%s', or the connection was closed.", name);
                }
            );
        }

        private void on_timelimit_alert_datetime_changed () {
            if (alert_timeout > 0) {
                debug ("on_timelimit_alert_datetime_changed: Removing scheduled notification.");
                GLib.Source.remove (alert_timeout);
            }

            var now = new GLib.DateTime.now_local ();
            var alert_datetime = now;
            if (timelimit_dbus_service.alert_datetime_iso8601 != "") {
                alert_datetime = new GLib.DateTime.from_iso8601 (timelimit_dbus_service.alert_datetime_iso8601, null);
            }

            var seconds_remaining = alert_datetime.difference (now) / 1000000;
            if (seconds_remaining > 0) {
                debug ("on_timelimit_alert_datetime_changed: Schedule notification.");

                alert_timeout = GLib.Timeout.add_seconds ((uint) seconds_remaining, () => {
                    var notification = new Notification (_("It's time!"));
                    notification.set_body (_("Your time limit is over."));
                    notification.set_priority (NotificationPriority.URGENT);

                    send_notification ("com.github.marbetschar.time-limit", notification);

                    return GLib.Source.REMOVE;
                });
            }
        }

        protected override void activate () {
            Gtk.main ();
        }
    }

    public static int main (string[] args) {
        OptionContext context = new OptionContext ("");
        context.add_main_entries (OPTIONS, null);

        try {
            context.parse (ref args);
        } catch (OptionError e) {
            error (e.message);
        }

        Granite.Services.Logger.initialize ("TimeLimit");
        Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.WARN;

        if (has_debug) {
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        }

        var app = new Daemon ();
        return app.run (args);
    }
}