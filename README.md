# ASD and TD saliency model comparison

I scored three published saliency models, FES, SalFBNet and TranSalNet, against fixation maps from autistic (ASD) and typically developing (TD) viewers, using four metrics over five images.

FES had the worst mean on every metric in both groups. Five images could not separate the two deep models, so I do not rank them.

## Question

Saliency models are trained on fixation data pooled from TD viewers. How do published models score against ASD fixation maps compared with TD maps, and what does each standard metric count when it scores them?

## Data and models

The notebooks read the images from `Saliency4asd.zip`. `evaluate.m` reads the group fixation maps from `TrainingData/TD_FixMaps` and `TrainingData/ASD_FixMaps`, which `TrainingData.zip` provides. The fixation map for `<name>.png` is `<name>_s.png`. The results files cover five images: 1, 10, 100, 101 and 102.

| Model | Type | Source | How I ran it |
|---|---|---|---|
| FES | Classical hand-designed feature model | [hrtavakoli/FES](https://github.com/hrtavakoli/FES) | MATLAB, `saliencyPredictionsCode/FES.m` |
| SalFBNet | Feedback-recurrent convolutional network | [gqding/SalFBNet](https://github.com/gqding/SalFBNet) | PyTorch on Colab, pretrained `FBNet_Res18Fixed_best_model.pth` |
| TranSalNet | Transformer-augmented encoder-decoder | [LJOVO/TranSalNet](https://github.com/LJOVO/TranSalNet) | PyTorch on Colab, pretrained `TranSalNet_Res.pth` |

I ran each model's published code, with pretrained weights for the two deep models. I did not retrain or fine-tune anything.

The metric implementations are the MIT Saliency Benchmark MATLAB functions from [cvzoya/saliency](https://github.com/cvzoya/saliency).

## Method

### Metrics

| Metric | Function | What it counts | Better |
|---|---|---|---|
| AUC-Borji | `AUC_Borji` | Location-based. Treats the saliency map as a binary classifier over pixels and draws an ROC curve, with negatives sampled uniformly from all pixels of the image. Only the ordering of pixel values matters, and there is no correction for centre bias. | Higher |
| CC | `CC` | Pearson correlation between the predicted map and the ground-truth map. It is symmetric, so false positives and false negatives cost the same. | Higher |
| KL divergence | `KLdiv` | Asymmetric. Near-zero predicted density where the ground truth has mass costs far more than density spread over unfixated regions. | Lower |
| NSS | `NSS` | Mean of the z-normalised saliency map at fixated pixels. A raised background lowers it. | Higher |

### Preprocessing

`evaluate.m` binarises each fixation map with `imbinarize` and passes that same binary map to all four metrics. CC and KL are therefore computed against a binary map, not a continuous fixation density. Predicted maps are scored as the models saved them, with no extra blur. An image is skipped unless both its TD and ASD fixation maps exist.

### Pipeline

1. `saliencyPredictionsCode/FES.m` and the two notebooks generate the saliency maps.
2. The maps go into `PredictionMaps/<Model>/` as PNG files named after the source image. No script does this step. `downloadAndUnzip.m` fetches a packaged `PredictionMaps.zip` instead.
3. `cloneMetricsCode.m` fetches the metric functions.
4. `evaluate.m` writes per-image scores, one CSV per model and group.
5. `visualize.m` plots the summary CSVs.

## Results

Means over five images, from `Results/TD_summary.csv` and `Results/ASD_summary.csv`. Higher is better for AUC-Borji, CC and NSS. Lower is better for KL.

TD fixation maps:

| Model | AUC-Borji | CC | KL | NSS |
|---|---|---|---|---|
| FES | 0.765 | 0.403 | 1.955 | 1.619 |
| SalFBNet | 0.875 | 0.733 | 0.906 | 3.115 |
| TranSalNet | 0.896 | 0.665 | 1.028 | 2.846 |

ASD fixation maps:

| Model | AUC-Borji | CC | KL | NSS |
|---|---|---|---|---|
| FES | 0.749 | 0.428 | 2.678 | 1.410 |
| SalFBNet | 0.789 | 0.640 | 1.221 | 2.186 |
| TranSalNet | 0.825 | 0.630 | 1.743 | 2.140 |

The summary files also hold the sample standard deviation behind each mean. The `TD_metrics_<Model>.csv` and `ASD_metrics_<Model>.csv` files hold the per-image scores.

## Findings and limitations

What the numbers support:

- FES has the worst mean on every metric in both groups.
- All three models have worse means on ASD maps under AUC-Borji, KL and NSS. Under CC the two deep models are worse on ASD maps and FES is marginally better, 0.428 against 0.403.
- SalFBNet and TranSalNet are not separable on this sample. TranSalNet has the higher mean AUC-Borji in both groups, and SalFBNet has the better mean CC, KL and NSS. No gap between them exceeds about 1.6 standard errors of the per-image differences, so I do not rank them.

That split is consistent with what each metric counts. AUC-Borji reads only the ordering of pixels, while CC, KL and NSS also read the map's magnitude and spread. Five images can illustrate that difference. They cannot establish it.

Limitations:

- Five images. Every result here is descriptive, and ranking the two deep models needs many more.
- One image moves the ASD KL means. Image 100 scores 6.691 for FES and 4.494 for TranSalNet. No other ASD KL value for those two models is above 2.210.
- Binarised ground truth. CC and KL here are not comparable with scores computed against continuous fixation density maps.
- No fixed seed. AUC-Borji samples its negatives at random and `evaluate.m` sets no seed, so a re-run can shift that column slightly.
- Group-level maps average over individuals. Any difference here is in aggregate, says nothing about a particular viewer, and does not support diagnostic use.
- Transfer only. This measures how TD-trained models transfer to ASD fixation data, not how to build an ASD-specific predictor.

## Reproducing

Requirements:

- MATLAB R2018b or later with the Image Processing Toolbox. The scripts call `isfolder`, `isfile`, `sgtitle` and `imbinarize`.
- `git` on the system path, and internet access. `FES.m` also calls `zip` on macOS and Linux.
- A Google account for Colab and Drive, only if you regenerate the SalFBNet and TranSalNet maps.

```bash
git clone https://github.com/m-nobinur/asd-td-saliency-comparison.git
```

Then in MATLAB, with the repository as the current folder:

```matlab
downloadAndUnzip    % TrainingData/ and PredictionMaps/
cloneMetricsCode    % metric functions, added to the path for this session
evaluate            % Results/TD_metrics_<Model>.csv and Results/ASD_metrics_<Model>.csv
visualize           % figures from Results/TD_summary.csv and Results/ASD_summary.csv
```

Three things to know before running:

- Data lives in the current folder as `TrainingData/TD_FixMaps`, `TrainingData/ASD_FixMaps` and `PredictionMaps/<Model>/*.png`. If `TrainingData.zip` or `PredictionMaps.zip` is already in the current folder, `downloadAndUnzip` unpacks that copy and skips the download.
- `evaluate.m` writes the per-image CSVs only. `TD_summary.csv` and `ASD_summary.csv` hold the mean and sample standard deviation of those per-image scores, and the code that wrote them is not in this repository. `visualize.m` reads the committed copies, so they go stale if you re-run `evaluate.m` on different data.
- `evaluate.m` and `visualize.m` clear the workspace when they start.

### Regenerating the saliency maps

This is optional, because `downloadAndUnzip` fetches a packaged `PredictionMaps.zip`.

**FES.** Run `saliencyPredictionsCode/FES.m`. Its paths are relative to MATLAB's current folder. It reads images from `TrainingData/Images`. If that folder does not exist, it creates it and unpacks `1.zip` from the current folder into it. I ran it in a hosted MATLAB session with an upload size limit, which is why the images arrive as a zip. The script clones the FES repository, writes `result/FES/<name>.png` and zips that folder as `FES.zip`.

**SalFBNet.** Open `saliencyPredictionsCode/SalFBNet.ipynb` in Google Colab. The saved notebook used a T4 GPU runtime. It expects `Saliency4asd.zip` at the top level of your Google Drive and asks you to upload `FBNet_Res18Fixed_best_model.pth`. It downloads `SalFBNet.zip`, which holds `results_Res18Fixed/Val_PseudoSal`.

**TranSalNet.** Open `saliencyPredictionsCode/TranSalNet.ipynb` in Google Colab with a GPU runtime. The inference cell casts its input to `torch.cuda.FloatTensor`, so it fails on CPU. It expects `Saliency4asd.zip` at the top level of Drive and the pretrained weights, including `TranSalNet_Res.pth`, in `MyDrive/Saliency/models/TransalNet`. It downloads `TranSalNet.zip`, which holds `output/TranSalNet`.

Afterwards, unpack the maps into `PredictionMaps/FES`, `PredictionMaps/SalFBNet` and `PredictionMaps/TranSalNet`. `evaluate.m` reads only `.png` files and treats every subfolder of `PredictionMaps/` as a model.

## Repository layout

```
.
├── downloadAndUnzip.m            fetch TrainingData/ and PredictionMaps/
├── cloneMetricsCode.m            fetch the metric code from cvzoya/saliency
├── evaluate.m                    score predictions, write per-image CSVs
├── visualize.m                   bar charts and heatmaps from the summary CSVs
├── saliencyPredictionsCode/
│   ├── FES.m                     FES maps, MATLAB
│   ├── SalFBNet.ipynb            SalFBNet maps, Colab
│   └── TranSalNet.ipynb          TranSalNet maps, Colab
├── Results/
│   ├── TD_metrics_<Model>.csv    per-image scores against TD maps
│   ├── ASD_metrics_<Model>.csv   per-image scores against ASD maps
│   ├── TD_summary.csv            mean and standard deviation per model
│   └── ASD_summary.csv
├── visuals/                      exported figures, see the note below
└── LICENSE
```

The figures in `visuals/` do not match the CSVs in `Results/` and need regenerating. Use the tables above.

## Licence

Apache License 2.0, see [LICENSE](LICENSE). It covers the code in this repository. The FES, SalFBNet and TranSalNet code and weights, the benchmark metric code and the dataset are not included here and keep their own terms.
