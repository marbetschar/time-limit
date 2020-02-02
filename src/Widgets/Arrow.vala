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

public class Timer.Widgets.Arrow : Gtk.DrawingArea {

    public double progress = 0.5;

    construct {
        set_size_request (25, 25);

        notify["progress"].connect(() => {
            debug ("progress.changed");
        });
    }

    public override bool draw (Cairo.Context context) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        context.move_to (0, 0);
        context.line_to (width / 2, height * 0.8);
        context.line_to (width, 0);
        context.close_path ();

        double angle = -progress * Math.PI * 2;
        //context.translate (width / 2, height / 2);
        context.rotate (angle);
        //context.translate (-(width / 2), -(height / 2));

        context.set_source_rgba (0.19845, 0.5485, 0.9665, 1);
        context.fill ();

        return true;

    /*
  override func draw(_ dirtyRect: NSRect) {
    NSColor.clear.setFill()
    self.bounds.fill()

    let path = NSBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))/
    path.line(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height * 0.8))
    path.line(to: CGPoint(x: self.bounds.width, y: 0))

    let cp = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    let angle = -progress * .pi * 2
    var transform = AffineTransform.identity
    transform.translate(x: cp.x, y: cp.y)
    transform.rotate(byRadians: angle)
    transform.translate(x: -cp.x, y: -cp.y)

    path.transform(using: transform)

    let windowHasFocus = self.window?.isKeyWindow ?? false
    if windowHasFocus {
      let ratio: CGFloat = 0.5
      NSColor(srgbRed: 0.1734 + ratio * (0.2235 - 0.1734), green: 0.5284 + ratio * (0.5686 - 0.5284), blue: 0.9448 + ratio * (0.9882 - 0.9448), alpha: 1.0).setFill()
    } else {
      NSColor(srgbRed: 0.5529, green: 0.6275, blue: 0.7216, alpha: 1.0).setFill()
    }
    path.fill()
  }
    */
    }
}
