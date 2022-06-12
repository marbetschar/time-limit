/*
* Copyright (c) 2022 Marco Betschart (https://marco.betschart.name)
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

    public ProgressIndicator (double progress) {
        Object (progress: progress);
    }

    construct {
        bar = new Timer.Widgets.ProgressBar (progress) {
            margin_top = 7,
            margin_bottom = 7,
            margin_start = 7,
            margin_end = 7,
            width_request = 186,
            height_request = 186
        };
        put (bar, 0, 0); // TODO: Calculate initial placing

        arrow = new Timer.Widgets.ProgressArrow (progress) {
            width_request = 25,
            height_request = 25
        };
        put (arrow, 90, 0); // TODO: Calculate initial placing

        bind_property ("progress", arrow, "progress", BindingFlags.BIDIRECTIONAL);
        bind_property ("progress", bar, "progress", BindingFlags.DEFAULT);

        notify["progress"].connect (() => {
            arrow_move (progress);
        });

        realize.connect (() => {
            arrow_move (progress);
        });
    }

    private void arrow_move (double progress) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        if (width < 1 || height < 1) {
            // if size is not allocated yet, we need to wait before we
            // move the arrow - otherwise it does not have any effect
            Timeout.add(100, () => {
                arrow_move (progress);
                return Source.REMOVE;
            });

        } else {
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
