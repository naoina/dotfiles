try:
    import matplotlib.pyplot as plt
except ModuleNotFoundError as e:
    print('{}: {}: {}: skipped'.format(__file__, e.__class__.__name__, e))
