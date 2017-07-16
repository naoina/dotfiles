try:
    import numpy as np
except ModuleNotFoundError:
    print('{}: {}: {}: skipped'.format(__file__, e.__class__.__name__, e))
