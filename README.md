# Comparison of Saliency Prediction Models for TD and ASD Fixations

This repository contains tools for processing saliency predictions. Below is a guide for cloning the repo, running the code on both Google Colab and MATLAB, and then evaluating the results by comparing prediction maps with fixation maps.

## Repository Setup

### Clone the Repository

To clone the repository, run the following command in your terminal:

```bash
git clone https://github.com/YourUsername/YourRepo.git
```

Replace `YourUsername/YourRepo.git` with the correct repository URL.

## Running the Code

### Using Google Colab

1. Open Google Colab.
2. Click on **File > Open notebook** and switch to the **GitHub** tab.
3. Paste the repository URL and select the desired notebook.
4. Run the code cells sequentially. The notebooks will automatically download and unzip the data, clone required external repos, and run the evaluation.

### Using MATLAB

1. Ensure that MATLAB has internet access.
2. Open MATLAB and navigate to the project folder.
3. Run the scripts in the following order:
   - `downloadAndUnzip.m`: Downloads and extracts training data and prediction maps.
   - `cloneMetricsCode.m`: Clones and sets up external metrics and visualization functions.
   - `evaluate.m`: Compares the predicted saliency maps with fixation maps (from TD and ASD folders), computes evaluation metrics, and outputs CSV files.
   - `visualize.m`: Reads CSV results and displays grouped bar charts and heatmaps of evaluation metrics.

## Evaluation Process

After setting up your environment (either on Google Colab or MATLAB), follow these steps:

1. **Download the Data and Prediction Maps**:  
   Run `downloadAndUnzip.m` to download the necessary training data (including fixation maps) and prediction maps.

2. **Clone External Metrics**:  
   Execute `cloneMetricsCode.m` to clone and organize the required code for computing evaluation metrics (AUC_Borji, CC, KLdiv, NSS).

3. **Evaluate Predictions**:  
   Run `evaluate.m` to compare each model’s prediction maps with the corresponding fixation maps. The script computes per-image metrics and saves detailed results as CSV files in the `Results` folder.

4. **Visualize the Results**:  
   Run `visualize.m` to generate bar charts and heatmaps that summarize and compare the evaluation metrics across different models.

## Deep Code Analysis

- **downloadAndUnzip.m**:  
  Handles data downloads and extraction. Read through to adjust file paths or URLs if needed.
- **cloneMetricsCode.m**:  
  Verifies the existence of external folders and clones the saliency metrics repo if necessary.
- **evaluate.m**:  
  Processes each prediction map, aligns it with corresponding fixation maps (TD and ASD), computes several metrics, and outputs CSV summaries.
- **visualize.m**:  
  Loads the CSV summaries and creates grouped bar charts and heatmaps to help analyze the performance over various models.

By reviewing each file, you can better understand the data flow, metric computations, and visualization logic. This will allow you to modify or extend the functionalities as required.

Happy Coding!
