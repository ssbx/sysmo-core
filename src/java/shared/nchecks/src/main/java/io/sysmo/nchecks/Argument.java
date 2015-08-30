/*
 * Sysmo NMS Network Management and Monitoring solution (http://www.sysmo.io)
 *
 * Copyright (c) 2012-2015 Sebastien Serre <ssbx@sysmo.io>
 *
 * This file is part of Sysmo NMS.
 *
 * Sysmo NMS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Sysmo NMS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Sysmo.  If not, see <http://www.gnu.org/licenses/>.
 */
package io.sysmo.nchecks;

public class Argument
{
    public static final int STRING_VALUE  = 1;
    public static final int INT_VALUE     = 2;

    private String   argumentString;
    private int      argumentInteger;
    private int      type;

    public void set(int val) {
        this.type = Argument.INT_VALUE;
        this.argumentInteger = val;
    }

    public void set(String val) {
        this.type = Argument.STRING_VALUE;
        this.argumentString = val;
    }

    public int asInteger() throws Exception,Error {
        if (type == Argument.STRING_VALUE) {
            return Integer.parseInt(this.argumentString);
        } else {
            return this.argumentInteger;
        }
    }

    public String asString() throws Exception, Error {
        if (type == Argument.INT_VALUE) {
            return Integer.toString(this.argumentInteger);
        } else {
            return this.argumentString;
        }
    }
}