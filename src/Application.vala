/*
* Copyright (c) 2020 Marco Betschart (https://marco.betschart.name)
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

public class Timer.Application : Gtk.Application {
    public static GLib.Settings settings;

    private MainWindow main_window;
    private GLib.DateTime? scheduled_notification_timer_start_datetime = null;
    private GLib.DateTime? scheduled_notification_timer_end_datetime = null;
    private uint scheduled_notification_timeout_id = 0;

    public Application () {
        Object (
            application_id: "com.github.marbetschar.time-limit",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings("com.github.marbetschar.time-limit");
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        main_window = new MainWindow (this) {
            title = "Time Limit"
        };

        int window_x, window_y;
        var rect = Gtk.Allocation ();

        settings.get ("window-position", "(ii)", out window_x, out window_y);
        settings.get ("window-size", "(ii)", out rect.width, out rect.height);

        if (window_x != -1 || window_y != -1) {
            main_window.move (window_x, window_y);
        }

        main_window.set_allocation (rect);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        main_window.show_all ();
        main_window.set_scheduled_notification_datetime (scheduled_notification_timer_end_datetime);

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (on_quit_action);

        main_window.schedule_notification.connect (on_schedule_notification);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run (args);
    }

    private void on_schedule_notification (GLib.DateTime? datetime) {
        scheduled_notification_timer_start_datetime = new GLib.DateTime.now_local ();
        scheduled_notification_timer_end_datetime = datetime;

        if (scheduled_notification_timeout_id > 0) {
            debug ("Remove scheduled notification");
            Granite.Services.Application.set_progress_visible.begin (false);

            GLib.Source.remove (scheduled_notification_timeout_id);
            scheduled_notification_timeout_id = 0;

            // allow app to quit:
            release ();
        }

        if (scheduled_notification_timer_end_datetime != null) {
            var now = new GLib.DateTime.now_local ();
            var seconds_remaining = datetime.difference (now) / 1000000;

            if (seconds_remaining > 0) {
                debug ("Schedule notification for: %s", datetime.format_iso8601 ());

                Granite.Services.Application.set_progress_visible.begin (true);
                Granite.Services.Application.set_progress.begin (0);

                scheduled_notification_timeout_id = GLib.Timeout.add_seconds (1, () => {
                    if (GLib.Source.REMOVE == scheduled_notification_tick_interval ()) {
                        var notification = new Notification (_("It's time!"));
                        notification.set_body (_("Your time limit is over."));
                        notification.set_priority (NotificationPriority.URGENT);

                        send_notification ("com.github.marbetschar.time-limit", notification);

                        scheduled_notification_timeout_id = 0;
                        Granite.Services.Application.set_progress_visible.begin (false);

                        // allow app to quit:
                        release ();

                        return GLib.Source.REMOVE;
                    }
                    return GLib.Source.CONTINUE;
                });

                // disallow app to quit:
                hold ();
            }
        }
    }

    private bool scheduled_notification_tick_interval () {
        if (scheduled_notification_timer_end_datetime != null) {
            var now = new GLib.DateTime.now_local ();
            var seconds_remaining = scheduled_notification_timer_end_datetime.difference (now) / 1000000;

            if (seconds_remaining <= 0) {
                return GLib.Source.REMOVE;
            }

            var seconds_total = scheduled_notification_timer_end_datetime.difference (scheduled_notification_timer_start_datetime) / 1000000;
            Granite.Services.Application.set_progress.begin (1.0 - ((double) seconds_remaining / seconds_total));
        }
        return GLib.Source.CONTINUE;
    }

    private void on_quit_action () {
        if (main_window != null) {
            main_window.destroy ();
        }
    }
}
