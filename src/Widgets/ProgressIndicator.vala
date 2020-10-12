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

public class Timer.Widgets.ProgressIndicator : Gtk.Fixed {

    public double progress { get; construct set; }

    public bool is_active {
        get {
            return arrow.is_active;
        }
    }

    private Timer.Widgets.ProgressArrow arrow;
    private Timer.Widgets.ProgressBar bar;

    private int arrow_width;
    private int arrow_height;

    public ProgressIndicator (double progress) {
        Object (progress: progress);
    }

    construct {
        bar = new Timer.Widgets.ProgressBar (progress);
        bar.margin = 7;
        add (bar);

        arrow = new Timer.Widgets.ProgressArrow (progress);
        put (arrow, 90, 0); // TODO: Calculate initial placing

        bind_property ("progress", arrow, "progress", BindingFlags.BIDIRECTIONAL);
        bind_property ("progress", bar, "progress", BindingFlags.DEFAULT);

        notify["progress"].connect (() => {
            arrow_move (progress);
        });

        arrow.size_allocate.connect (() => {
            arrow_width = arrow.get_allocated_width ();
            arrow_height = arrow.get_allocated_height ();
        });

        button_press_event.connect ((event) => {
            return arrow.button_press_event (event);
        });

        button_release_event.connect ((event) => {
            return arrow.button_release_event (event);
        });

        motion_notify_event.connect ((event) => {
            return arrow.motion_notify_event (event);
        });

        size_allocate.connect ((allocation) => {
            bar.size_allocate (allocation);
        });
    }

    public bool handles_event (Gdk.Event event) {
        if (arrow.is_active) {
            return true;
        }
        double event_x, event_y;
        int arrow_min_x, arrow_min_y, arrow_max_x, arrow_max_y;

        event.get_coords (out event_x, out event_y);

        event_x += arrow_width / 2;
        event_y += arrow_height / 2;

        arrow.translate_coordinates (base, 0, 0, out arrow_min_x, out arrow_min_y);
        arrow.translate_coordinates (base, arrow_width, arrow_height, out arrow_max_x, out arrow_max_y);

        return event_x >= arrow_min_x && event_x <= arrow_max_x && event_y >= arrow_min_y && event_y <= arrow_max_y;
    }

    private void arrow_move (double progress) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        if (width > 1 && height > 1) {
            int arrow_width = arrow.get_allocated_width ();
            int arrow_height = arrow.get_allocated_height ();

            int content_width = width - arrow_width;
            int content_height = height - arrow_height;

            var angle = progress * Math.PI * 2 - Math.PI / 2;
            var delta_x = content_width / 2 + Math.cos (angle) * content_width / 2;
            var delta_y = content_height / 2 + Math.sin (angle) * content_height / 2;

            move (arrow, (int) delta_x, (int) delta_y);
        }
    }
}
