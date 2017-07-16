try:
    import pandas as pd
    pd.set_option('display.width', 100)
except ModuleNotFoundError as e:
    print('{}: {}: {}: skipped'.format(__file__, e.__class__.__name__, e))
