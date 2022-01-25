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

namespace Tests.Util {

    class TruncatingRemainder : TestCase {

        // test env variables need to be static:
        private static string test_value = null;

        public TruncatingRemainder () {
            base (
                "TruncatingRemainder",
                set_up,  // or: null
                test,
                tear_down  // or: null
            );
        }

        void set_up () {
            test_value = "my-test-value";
        }

        void test () {
            assert_true (1.0 == Timer.Util.truncating_remainder (5.0, 4.0));
            assert_true (0.0 == Timer.Util.truncating_remainder (7.0, 7.0));

            assert_nonnull (test_value);
            assert_true ("my-test-value" == test_value);
            // https://docs.gtk.org/glib/func.assert_cmpstr.html
            // assert_cmpstr (test_value, ==, "my-test-value");
        }

        void tear_down () {
            test_value = null;
        }
    }

    void test_truncating_remainder () {
        assert_true (1.0 == Timer.Util.truncating_remainder (5.0, 4.0));
        assert_true (0.0 == Timer.Util.truncating_remainder (7.0, 7.0));
    }
}