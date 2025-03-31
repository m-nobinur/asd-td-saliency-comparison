# Comparative Analysis of Saliency Prediction Models for ASD and TD Fixation

This repository contains tools for processing saliency predictions and comparing their performance on Autism Spectrum Disorder (ASD) and Typically Developing (TD) fixation maps. Below is a guide for cloning the repo, generating saliency prediction maps using selected models, running the evaluation code on both Google Colab and MATLAB, and then analyzing the results.

## Repository Setup

### Clone the Repository

To clone the repository, run the following command in your terminal:

```bash
git clone https://github.com/m-nobinur/asd-td-saliency-comparison.git
```

## Saliency Prediction Models

I selected three state-of-the-art saliency prediction models for this comparative analysis. These models were chosen after extensive testing of various saliency models, as many older models had compatibility issues with current environments or produced poor-quality results.

### Selected Models

1. **FES (Fast and Efficient Saliency)**: 
   - A MATLAB-based model that offers a good balance between computational efficiency and prediction quality
   - Uses color features and prior knowledge to generate saliency maps
   - Selected for its reliable performance and compatibility with my evaluation framework

2. **SalFBNet (Saliency Feedback Network)**:
   - A deep learning-based model implemented in PyTorch
   - Utilizes a feedback mechanism to refine saliency predictions
   - Selected for its state-of-the-art performance on benchmark datasets and modern architecture

3. **TranSalNet (Transformer Saliency Network)**:
   - A transformer-based model that leverages attention mechanisms
   - Provides high-quality saliency predictions with good generalization capabilities
   - Selected for its modern architecture and strong performance on diverse image types

### Why These Models?

During model selection, I encountered several challenges with other saliency models:

- Many older models had dependencies on outdated libraries or frameworks
- Some models produced inconsistent or poor-quality saliency maps
- Several models had limited documentation or were difficult to integrate
- Some models required extensive computational resources or had slow inference times

The three selected models provided the best combination of prediction quality, computational efficiency, and compatibility with my evaluation framework.

## Generating Saliency Prediction Maps

Before evaluation, you need to generate saliency prediction maps using the models in the `saliencyPredictionsCode` folder:

### FES Model

1. Open MATLAB and navigate to the project folder.
2. Upload the training images to `TrainingData/Images` folder.
   - I uploaded 1.zip and 2.zip (training images) to the MATLAB server. The code will automatically extract the images from the zip files into the `TrainingData/Images` folder.
3. Run `saliencyPredictionsCode/FES.m` script.
4. The script will:
   - Clone the FES repository if it doesn't exist
   - Add the repository to the MATLAB path
   - Extract image files from the training data
   - Process each image to generate saliency maps
   - Save the results in the `result/FES/` directory
   - Create a zip file of the results for easy download

### SalFBNet Model

1. Open the `saliencyPredictionsCode/SalFBNet.ipynb` notebook in Google Colab.
2. Run the cells sequentially to:
   - Clone the SalFBNet repository
   - Mount your Google Drive to access the dataset
   - Extract the dataset to the appropriate directory
   - Load the pre-trained model
   - Generate saliency maps for all images
   - Save the results to your Google Drive

### TranSalNet Model

1. Open the `saliencyPredictionsCode/TranSalNet.ipynb` notebook in Google Colab.
2. Run the cells sequentially to:
   - Clone the TranSalNet repository
   - Mount your Google Drive to access the dataset
   - Extract the dataset to the appropriate directory
   - Set up the model architecture and load pre-trained weights
   - Generate saliency maps for all images
   - Save the results to your Google Drive

## Running the Evaluation Code

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

After generating the saliency prediction maps, follow these steps to evaluate and compare their performance:

1. **Download the Data and Prediction Maps**:  
   Run `downloadAndUnzip.m` to download the necessary training data (including fixation maps) and prediction maps.

2. **Clone External Metrics**:  
   Execute `cloneMetricsCode.m` to clone and organize the required code for computing evaluation metrics (AUC_Borji, CC, KLdiv, NSS).

3. **Evaluate Predictions**:  
   Run `evaluate.m` to compare each model's prediction maps with the corresponding fixation maps. The script computes per-image metrics and saves detailed results as CSV files in the `Results` folder.

4. **Visualize the Results**:  
   Run `visualize.m` to generate bar charts and heatmaps that summarize and compare the evaluation metrics across different models.

## Deep Code Analysis

### Saliency Prediction Code

- **FES.m**:  
  MATLAB script that implements the Fast and Efficient Saliency model. It clones the FES repository, processes images, and generates saliency maps using color features and prior knowledge.

- **SalFBNet.ipynb**:  
  Google Colab notebook that implements the Saliency Feedback Network model. It uses a deep learning approach with feedback mechanisms to generate high-quality saliency maps.

- **TranSalNet.ipynb**:  
  Google Colab notebook that implements the Transformer Saliency Network model. It leverages transformer architecture and attention mechanisms for saliency prediction.

### Evaluation and Visualization Code

- **downloadAndUnzip.m**:  
  Handles data downloads and extraction. Read through to adjust file paths or URLs if needed.

- **cloneMetricsCode.m**:  
  Verifies the existence of external folders and clones the saliency metrics repo if necessary.

- **evaluate.m**:  
  Processes each prediction map, aligns it with corresponding fixation maps (TD and ASD), computes several metrics (AUC_Borji, CC, KLdiv, NSS), and outputs CSV summaries in the `Results` folder.

- **visualize.m**:  
  Loads the CSV summaries and creates grouped bar charts and heatmaps to help analyze the performance over various models. The visualizations highlight differences in how each model performs on TD versus ASD fixation maps.

### Results Analysis

The evaluation generates several CSV files in the `Results` folder:

- Individual metric files for each model and group (e.g., `TD_metrics_FES.csv`, `ASD_metrics_SalFBNet.csv`)
- Summary files that aggregate metrics across all models for each group (`TD_summary.csv`, `ASD_summary.csv`)

The visualization produces:

- Bar charts comparing model performance across different metrics
- Heatmaps showing the relative performance of models for TD and ASD groups
