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

public class Timer.MainWindow : Hdy.ApplicationWindow {

    public signal void schedule_notification (GLib.DateTime? datetime);
    private uint configure_id;
    private Timer.Widgets.Clock clock;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.marbetschar.time-limit",
            resizable: false,
            default_height: 225,
            default_width: 200
        );
    }

    static construct {
        Hdy.init ();
    }

    construct {
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/marbetschar/time-limit/");

        var header = new Hdy.HeaderBar () {
            has_subtitle = false,
            decoration_layout = "close:",
            show_close_button = true,
            valign = Gtk.Align.START
        };

        header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        clock = new Timer.Widgets.Clock (header);
        add (clock);

        key_release_event.connect ((event) => {
            switch (event.keyval) {
                case Gdk.Key.space:
                    clock.pause = !clock.pause;
                    if (clock.pause) {
                        schedule_notification (null);
                    } else {
                        schedule_notification (new GLib.DateTime.now_local ().add_seconds (clock.seconds));
                    }
                    break;

                case Gdk.Key.Escape:
                    clock.pause = false;
                    clock.seconds = 0;
                    schedule_notification (null);
                    break;
            }
        });
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            if (is_maximized) {
                Timer.Application.settings.set_boolean ("window-maximized", true);
            } else {
                Timer.Application.settings.set_boolean ("window-maximized", false);

                Gdk.Rectangle rect;
                get_allocation (out rect);
                Timer.Application.settings.set ("window-size", "(ii)", rect.width, rect.height);

                int root_x, root_y;
                get_position (out root_x, out root_y);
                Timer.Application.settings.set ("window-position", "(ii)", root_x, root_y);
            }

            return Source.REMOVE;
        });

        return base.configure_event (event);
    }

    public void set_scheduled_notification_datetime (GLib.DateTime? datetime) {
        if (datetime == null) {
            clock.seconds = 0;

        } else {
            var now = new GLib.DateTime.now_local ();
            clock.seconds = datetime.difference (now) / 1000000;

            clock.pause = false;
            clock.start_ticking ();
        }
    }
}
