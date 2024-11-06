#!/usr/bin/env python3

# see https://github.com/prometheus/docs/blob/main/content/docs/instrumenting/exposition_formats.md

from prometheus_client.parser import text_string_to_metric_families
import sys

def validate_prometheus_metrics(file_path):
    """
    Parses a file containing Prometheus metrics and checks for correct formatting.

    Parameters:
    - file_path: Path to the file containing Prometheus metrics.

    Returns:
    - None
    """
    try:
        with open(file_path, 'r') as f:
            metrics_data = f.read()

        # Attempt to parse the metrics using the Prometheus client parser
        for metric_family in text_string_to_metric_families(metrics_data):
            print(f"Metric Family: {metric_family.name}")
            for sample in metric_family.samples:
                print(f"  Sample: {sample}")

        print("File is correctly formatted for Prometheus metrics.")

    except Exception as e:
        print(f"Error: The file is not correctly formatted.\nDetails: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_metrics.py <path_to_metrics_file>")
    else:
        file_path = sys.argv[1]
        validate_prometheus_metrics(file_path)
