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
def validate_prometheus_metrics(metrics_data, quiet=False):
    # Attempt to parse the metrics using the Prometheus client parser
    for metric_family in text_string_to_metric_families(metrics_data):
        # if not quiet:
        #     print(f"Metric Family: {metric_family.name}")
        for sample in metric_family.samples:
            if not quiet:
                print(f"  Sample: {sample}")
            if args.check_for_decimal_timestamps:
                # check that the timestamp isn't a non-zero decimal
                if any("." in str(sample.timestamp) and not str(sample.timestamp).endswith(".0") for sample in metric_family.samples):
                    raise ValueError("Timestamps must be specified as epoch seconds, non-zero decimals are not allowed.")

if __name__ == "__main__":
    # use agparse to parse the arguments
    import argparse
    parser = argparse.ArgumentParser(description="Validate Prometheus metrics.")
    # add a flag for --quiet mode
    parser.add_argument("-q", "--quiet", action="store_true", help="Only output errors.")
    parser.add_argument("metrics_file", nargs='?', help="The path to the file containing the Prometheus metrics. If not provided, input is read from stdin.")
    # add a flag for disabling decimal timestamp checking, store it in args.check_for_decimal_timestamps
    parser.add_argument("-d", "--no-decimal-timestamp-checking", dest="check_for_decimal_timestamps", action="store_false", help="Do not check for non-zero decimal timestamps.")
    args = parser.parse_args()

    metrics_data = load_file(args.metrics_file) if args.metrics_file else sys.stdin.read()
    if metrics_data is None:
        sys.exit(1)

    try:
        validate_prometheus_metrics(metrics_data, quiet=args.quiet)
    except Exception as e:
        print(f"❌ Error: File/content is invalid. Exception: {e}")
        sys.exit(1)

    # celebrate success
    #
    # saluting person
    # print("🫡 😁 " * 8)
    # dice time
    # print("🎲 🧨 " * 8)
    #
    # simpler
    print("✅ Success: File/content is valid!")
