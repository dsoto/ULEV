This folder contains a VESC package display battery information from a VESC-compatible BMS and display in a custom display in VESC-Tool.

There is a lisp script that tallies the internal resistance, gets the high and low cell row voltages, and gets the battery temperature.
It then sends these over to VESC tool and a qml script places them on display gauges.