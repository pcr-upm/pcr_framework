<h1 align="center">
<img src="https://github.com/user-attachments/assets/cb968883-19a2-4e97-8cb2-a752f75f1274" width="300">
</h1><br>

[![PyPI version](https://badge.fury.io/py/pcr-framework.svg)](https://badge.fury.io/py/pcr-framework)

### Requisites
The required dependencies are installed in the [`Dockerfile`](./Dockerfile#L31-32).

### Installation
```bash
pip install pcr-framework
```

This will automatically install most dependencies.

**Important:** GDAL is not installed automatically via `pip`.
```bash
conda install -c conda-forge gdal
```

### Usage
You can run the provided test script to check the library:
```bash
python pcr_framework/test/pcr_framework_test.py
```

### Main features
#### Load and manage data
Load and manage datasets, annotations, images, and video sequences. The library provides a unified data representation for different computer vision tasks.
```python
import numpy as np
from pcr_framework.src.annotations import GenericVideo, GenericImage

# Prepare annotations and predictions.
# GenericVideo represents a set of images or a sequence of frames from a video
# for solving a generic computer vision problem.
ann, pred = GenericVideo(), GenericVideo()

# For example, you can split an image into smaller tiles (regions of interest)
# and process each part separately.
for roi in [[0, 0, 600, 600], [0, 600, 600, 1200], [0, 1200, 600, 1800]]:
    img_pred = GenericImage('pcr_framework/test/example.tif')
    img_pred.tile = np.array(roi)
    pred.add_image(img_pred)
```

```python
import tempfile
from tqdm import tqdm
from datasets import load_dataset
from pcr_framework.src.datasets import Database, Sources

# Annotations can be loaded directly or through the built-in dataloaders 
# (src/datasets.py), which support multiple data sources and formats, 
# including TXT files, TensorFlow datasets, and Hugging Face datasets.
datasets = [subclass().get_names() for subclass in Database.__subclasses__()]
idx = next((idx for idx, subset in enumerate(datasets) if 'mnist' in subset), None)
anns = []
path = tempfile.gettempdir()
kwargs = {'path': 'ylecun/mnist', 'cache_dir': path, 'split': 'test', 'download_mode': 'force_redownload'}
ds = load_dataset(**kwargs)
for line in tqdm(ds, file=sys.stdout):
    ann = Database.__subclasses__()[idx]().load_line(Sources.HUGFACE, 'mnist', path, line)
    if len(ann.images) == 0:
        continue
    anns.append(ann)
```

#### Integrate and execute computer vision components
Load, configure, and execute different computer vision modules through a unified interface. These components include object detection, segmentation, classification, regression, reconstruction, and other vision-related tasks.
```python
from pcr_framework.src.composite import Composite
from pcr_framework.detection.ssd16_detection.src.ssd16_detection import SSD16Detection

# Composite class acts as a container where you can plug in different computer 
# vision modules such as detectors, segmentators, regressors, classifiers, etc.
composite = Composite()
sd = SSD16Detection('pcr_framework/detection/ssd16_detection/')
composite.add(sd)

# Once the modules are incorporated, you can call process() to run them over 
# the frames.
composite.process(ann, pred)
```

#### Visualize results
Visualize images, annotations, predictions, and processing results using the `Viewer` class.
```python
from pcr_framework.src.viewer import Viewer

# Viewer class is used to visualize the results of the processing.
viewer = Viewer('pcr_framework_test')
for img_pred in pred.images:
    viewer.set_image(img_pred)

composite.show(viewer, ann, pred)
```

#### Metrics evaluation
Compute evaluation metrics to quantitatively assess the performance of computer vision models.
```python
ofs = open('pcr_framework/output/results.txt', 'w', encoding='utf-8')
composite.evaluate(ofs, ann, pred)
ofs.close()
```

```bash
python pcr_framework/output/eval_detection.py
```

### Contributions
The [PCR-UPM](https://pcr-upm.github.io/) group welcomes your expertise and enthusiasm!

Small improvements or fixes are always appreciated. If you are considering larger contributions to the source code, please contact bobetocalo@gmail.com first.
