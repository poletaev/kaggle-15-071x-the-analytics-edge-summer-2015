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

The [area under the curve (AUC)](https://en.wikipedia.org/wiki/Receiver_operating_characteristic#Area_under_the_curve) was used as performance metric.

## Result models

To train and evaluate each model train data from *eBayiPadTrain.csv* was split into 80% train set and 20% cross-validation set. For eeach model performance was measured on cross-validation set unless otherwise stated explicitly. Also for each model [ROC curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic) was plotted to illustrate overall performance, as AUC might not be easily interpretable. The best performance on the whole test set (from *eBayiPadTest.csv*) has been showed by the first version (more simple than final) of Logistic Regression: 0.85155 and final 790 place of 1884 on private leaderboard.

### Random Forest (RF)

The source code of this model is in [random-forest.R](/src/random-forest.R).

* CV accuracy: 0.6997273
* CV sensitivity (true posititive rate): 0.7203573
* CV specificity (true negative rate): 0.6819855
* CV set AUC: 0.8915262
* Train data AUC: 0.9981691

Post-deadline submission of this model's prediction shows 0.84875 and 1095 place on private leaderboard.

![ROC for Random Forest model on cross-validation data](/doc/RF-ROC-on-CV.png)

### Classification and regression trees (CART)

The source code of this model is in [cart.R](/src/cart.R).

* Train data Accuracy: 0.7382321
* Train data Sensitivity (true posititive rate): 0.7738663
* Train data Specificity (true negative rate): 0.7076174
* Train data AUC: 0.8910543
* Cross-validation train data AUC: 0.8409012

Post-deadline submission of this model's prediction shows 0.81753 and 1673 place on private leaderboard.

![ROC for CART model on cross-validation data](/doc/CART-ROC-on-CV.png)

### RF and CART based on term frequency of words from description

Implimentation of this model is in [language-model.R](/src/language-model.R). It contains two models: RF and CART trained on term frequency matrix built of description field. None of these models has shown good enough performance, so no submission was sent to Kaggle.

* RF cross-validation train data accuracy: 0.5402537
* RF cross-validation train data sensitivity (true posititive rate): 0.3052574
* RF cross-validation train data specificity (true negative rate): 0.7423504
* RF cross-validation train data AUC: 0.5471948
* RF train data AUC: 0.6620095

![ROC for RF on cross-validation data of term frequencies](/doc/language-RF-ROC-on-CV.png)

* CART train data accuracy: 0.557936
* CART train data sensitivity (true posititive rate): 0.5816376
* CART train data specificity (true negative rate): 0.537578
* CART train data AUC: 0.6618262
* CART cross-validation train data AUC: 0.5901453

![ROC for CART on cross-validation data of term frequencies](/doc/language-CART-ROC-on-CV.png)

CART model built following decision tree:
![CART on train set of term frequencies](/doc/language-CART-tree.png)

### Logistic Regression

The source code of this model is in [logistic-regression.R](/src/logistic-regression.R).

* Ratio of residual deviance to the residual degreees of freedom for model: 0.9376546
* Cross-validation train data accuracy: 0.6839694
* Cross-validation train data sensitivity (true posititive rate): 0.7099574
* Cross-validation train data specificity (true negative rate): 0.6616197
* Cross-validation train data AUC: 0.8693605

Post-deadline submission of this model's prediction shows 0.84568 and 1278 place on private leaderboard.
While the best of sent submissions (logistic-regression-model.csv) shows 0.83519 on public and 0.85155 on private leaderboard.

![ROC for cross-validation data](/doc/LR-ROC-on-CV.png)
