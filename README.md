# 15.071x - The Analytics Edge (Summer 2015)

## Description

The full description is available by the [following link](https://inclass.kaggle.com/c/15-071x-the-analytics-edge-summer-2015).

The goal of this competition was to develop model which predict if eBay listing of iPads will be successful based on following data:

* **description** = The text description of the product provided by the seller.
* **biddable** = Whether this is an auction (biddable=1) or a sale with a fixed price (biddable=0).
* **startprice** = The start price (in US Dollars) for the auction (if biddable=1) or the sale price (if biddable=0).
* **condition** = The condition of the product (new, used, etc.)
* **cellular** = Whether the iPad has cellular connectivity (cellular=1) or not (cellular=0).
* **carrier** = The cellular carrier for which the iPad is equipped (if cellular=1); listed as "None" if cellular=0.
* **color** = The color of the iPad.
* **storage** = The iPad's storage capacity (in gigabytes).
* **productline** = The name of the product being sold.

## Result models
### Random Forest (RF)
cross-validation train data Accuracy: 0.6997273
cross-validation train data Sensitivity (true posititive rate): 0.7203573
cross-validation train data Specificity (true negative rate): 0.6819855
cross-validation train data AUC: 0.8915262
train data AUC: 0.9981691

1095 Andrey	0.84875 Post-Deadline

![ROC for cross-validation data](/doc/RF-ROC-on-CV.png)


### Classification and regression trees (CART)
train data Accuracy: 0.7382321
train data Sensitivity (true posititive rate): 0.7738663
train data Specificity (true negative rate): 0.7076174
train data AUC: 0.8910543
cross-validation train data AUC: 0.8409012

1673 Andrey	0.81753 Post-Deadline

![ROC for cross-validation data](/doc/CART-ROC-on-CV.png)

### RF and CART based on term frequency of description

Implimentation of this model is in language-model.R

RF cross-validation train data Accuracy: 0.5402537
RF cross-validation train data Sensitivity (true posititive rate): 0.3052574
RF cross-validation train data Specificity (true negative rate): 0.7423504
RF cross-validation train data AUC: 0.5471948
RF train data AUC: 0.6620095

![ROC for cross-validation data](/doc/language-RF-ROC-on-CV.png)

CART train data Accuracy: 0.557936
CART train data Sensitivity (true posititive rate): 0.5816376
CART train data Specificity (true negative rate): 0.537578
CART train data AUC: 0.6618262
CART cross-validation train data AUC: 0.5901453

![ROC for cross-validation data](/doc/language-CART-ROC-on-CV.png)

### Logistic Regression

ratio of residual deviance to the residual degreees of freedom for model: 0.9376546
cross-validation train data Accuracy: 0.6839694
cross-validation train data Sensitivity (true posititive rate): 0.7099574
cross-validation train data Specificity (true negative rate): 0.6616197
cross-validation train data AUC: 0.8693605

1278 Andrey	0.84568 Post-Deadline

The best of submissions
790	logistic-regression-model.csv	0.83519	0.85155

![ROC for cross-validation data](/doc/LR-ROC-on-CV.png)
