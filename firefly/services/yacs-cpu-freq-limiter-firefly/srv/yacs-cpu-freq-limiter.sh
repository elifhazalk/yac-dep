#!/bin/bash

echo "before (min):"
grep . /sys/devices/system/cpu/cpufreq/policy*/scaling_min_freq

echo "before (max):"
grep . /sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq

MAX_FREQ_POLICY_0=1200000
MAX_FREQ_POLICY_4=1800000
MAX_FREQ_POLICY_6=1800000

MIN_FREQ_POLICY_0=408000
MIN_FREQ_POLICY_4=408000
MIN_FREQ_POLICY_6=408000

echo $MAX_FREQ_POLICY_0 | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
echo $MAX_FREQ_POLICY_4 | sudo tee /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
echo $MAX_FREQ_POLICY_6 | sudo tee /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq

echo $MIN_FREQ_POLICY_0 | sudo tee /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo $MIN_FREQ_POLICY_4 | sudo tee /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
echo $MIN_FREQ_POLICY_6 | sudo tee /sys/devices/system/cpu/cpufreq/policy6/scaling_min_freq

echo "after (min):"
grep . /sys/devices/system/cpu/cpufreq/policy*/scaling_min_freq

echo "after (max):"
grep . /sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq