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
* Authored by: Marco Betschart <elementary-timer@marco.betschart.name
*/

public class Timer.Widgets.ProgressIndicator : Gtk.Fixed {

    public double progress { get; construct set; }
    public signal void progress_changed (double progress);

    private Timer.Widgets.ProgressArrow arrow;
    private Timer.Widgets.ProgressBar bar;

    public ProgressIndicator (double progress) {
        Object (progress: progress);
    }

    construct {
        bar = new Timer.Widgets.ProgressBar (progress);
        bar.margin = 7;
        put (bar, 0, 0);

        arrow = new Timer.Widgets.ProgressArrow (progress);
        put (arrow, 86, 0); // TODO: Calc initial position dynamically

        notify["progress"].connect (() => {
            debug ("forward.progress: %f", progress);
            arrow.progress = progress;
        });

        arrow.progress_changed.connect ((progress) => {
            debug ("progress_changed");
            arrow_move (progress);
            bar.progress = progress;
            progress_changed (progress);
        });
    }

    private void arrow_move (double progress) {
        int arrow_width = arrow.get_allocated_width ();
        int arrow_height = arrow.get_allocated_height ();

        int content_width = get_allocated_width () - arrow_width;
        int content_height = get_allocated_height () - arrow_height;

        var angle = progress * Math.PI * 2 - Math.PI / 2;
        var delta_x = content_width / 2 + Math.cos (angle) * content_width / 2;
        var delta_y = content_height / 2 + Math.sin (angle) * content_height / 2;

        move (arrow, (int) delta_x, (int) delta_y);
    }
}
