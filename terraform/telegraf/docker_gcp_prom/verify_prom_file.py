#!/usr/bin/env python3

# see https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md

from prometheus_client.parser import text_string_to_metric_families
import sys

# Load the file from the given path
def load_file(file_path):
    try:
        with open(file_path, 'r') as f:
            return f.read()
    except Exception as e:
        print(f"Error: Could not load the file.\nDetails: {e}")
        return None

# Validate the Prometheus metrics
def validate_prometheus_metrics(metrics_data):
    # Attempt to parse the metrics using the Prometheus client parser
    try:
        for metric_family in text_string_to_metric_families(metrics_data):
            print(f"Metric Family: {metric_family.name}")
            for sample in metric_family.samples:
                print(f"  Sample: {sample}")
    except Exception as e:
        print(f"Error: Could not parse the metrics.\nDetails: {e}")
        return

if __name__ == "__main__":
    # Ensure the correct number of arguments are provided
    if len(sys.argv) != 2:
        print("Usage: python validate_metrics.py <path_to_metrics_file>")
    # Read the metrics data from the file or stdin
    elif sys.argv[1] == "-":
        metrics_data = sys.stdin.read()
    # Read the metrics data from the file
    else:
        metrics_data = load_file(sys.argv[1])
    validate_prometheus_metrics(metrics_data)

    # show success message
    if metrics_data:
        # saluting person
        print("🫡 😁 " * 8)
        print("    File validated successfully!")
        # dice time
        print("🎲 🧨 " * 8)









