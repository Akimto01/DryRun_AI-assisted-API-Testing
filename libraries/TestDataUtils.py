import random
import string
import time


def generate_unique_name(prefix="TEST"):
    timestamp = int(time.time() * 1000)
    suffix = "".join(random.choices(string.ascii_uppercase, k=4))
    return f"{prefix}_{timestamp}_{suffix}"
