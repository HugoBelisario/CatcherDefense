# CatcherDefense

## Introduction

A catcher's impact on defense extends beyond the traditional performance indicators such as throwing ability, agility behind home plate, and preventing passed balls. It would be foolish to judge a catcher based simply on the number of steals allowed or their caught stealing percentage (CS%) because there are several factors that influence the probability of a steal attempt including the specific pitcher and runner involved. 

Data-driven MLB teams are always hungry for the latest edge to maximize and implement before copycats drive its effectiveness down. In Travis Sawchik's "Big Data Baseball", the Pittsburgh Pirates tapped into the framing and game calling abilities of Russell Martin for a two-year stint that ended a 20-year losing record streak and clinched postseason berths by eliminating the woes of several on the Bucs' rotation and bullpen. Pitch framing involves receiving the ball and catching in a manner that favors the pitcher with a strike located outside of standard zones, but in the specific umpire's zone. Another key component of a catcher's skillset, mentioned before, is the ability to prevent runners from advancing and scoring on wild pitches and passed balls by blocking. The optimal way to prevent a steal is to prevent the runner from even attempting it. To achieve this level of hesitation and respect from the runner, the catcher must have elite pop times, exchange times, and arm strength. Pop time measures the time from the moment the pitch hits the catcher's mitt to the moment the ball reaches the fielder's projected receiving point at the center of the base. It is a combination of exchange time (how quickly the catcher releases the ball, measured in seconds) and arm strength (velocity of throw, in MPH).

The datasets used for this project came from Baseball Prospectus (BP), a leading website and community in sabermetric analysis of baseball, and Baseball Savant, a site dedicated to providing player matchups, Statcast metrics, and advanced statistics in a simple and easy-to-view way. BP recently built a new Leaderboards platform that is currently in Beta and includes Hitting, Pitching, and Catcher Defensive Leaderboards. They have developed an overall defensive measure for catchers called Catcher Defensive Adjustment (CDA) or Fielding Runs Above Average Adjustment (FRAA). However, this leaderboard does not contain Statcast metrics for framing, pop time, and exchange. For these metrics, I extracted data from BaseballSavant's Statcast Leaderboards. BaseballSavant breaks down the catcher's view into eight zones around the strike zone and shows the called strike percentage of all non-swings in that zone. Framing stats measure how many runs catchers save based on how many extra strikes they provide for their pitchers. Statcast was set up in all 30 stadiums starting in 2015, so I am only using seasonal data since then for this project.

Since advanced performance metrics for catchers are constantly being altered and improved upon, there are distinct methods of evaluating players in this crucial position. BP, being an entity outside of the game without access to proprietary data from MLB's Statcast technology sparked my question of interest: Can we predict a catcher's overall defensive value using Statcast data to replace metrics used by Baseball Prospectus? I believe so. My assumption is grounded in the notion that Statcast serves as the most accurate way of predicting a catcher's defensive abilities than outsiders conducting independent research with publicly available data. In contrast to BP, BaseballSavant does not provide a comprehensive defensive measure for catchers. Furthermore, my belief is that, although there are similarities to statistics provided by both institutions, using Statcast metrics can give us more insight into catcher defense utilizing BP's formula for CDA. 

## Codebook

maxeff_arm_2b_3b_sba: arm strength measured on “max effort” throws, or the average above a player’s 90th percentile performance, in miles per hour (MPH)

exchange_2b_3b_sba: exchange time measured in seconds

pop_2b_sba: pop time to second base in seconds

runs_extra_strikes: strikes to runs saved on a .125 run/strike basis, and includes park and pitcher adjustments

strike_rat: cumulative total of all zones, percentages of called strikes from pitches that were not swung at in zones 11-17.

strike_rate_11: percentages of called strikes from all called pitches in zone 11

strike_rate_12: percentages of called strikes from all called pitches in zone 12

strike_rate_13: percentages of called strikes from all called pitches in zone 13

strike_rate_14: percentages of called strikes from all called pitches in zone 14

strike_rate_16: percentages of called strikes from all called pitches in zone 16

strike_rate_17: percentages of called strikes from all called pitches in zone 17

strike_rate_18: percentages of called strikes from all called pitches in zone 18

strike_rate_19: percentages of called strikes from all called pitches in zone 19

fraa_adj: catcher defensive adjustment or fielding runs above average adjustment

fraa: fielding runs above average

epaa_runs: errant pitches above average also known as blocking runs

### Simple Linear Regression

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.15.32%20PM.png)

Fielding Runs Above Average, Runs From Extra Strikes, Strike Rate, Strike Rate in Zone 18, Blocking Runs, Strike Rate in Zone 19, Strike Rate in Zone 17, and Strike Rate in Zone 16 had statistically significant estimates.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/unnamed-chunk-11-1.png)

A table that details the relationship between all of the variables and Catcher Defensive Adjustment in scatterplots with linear regression lines.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.42.50%20PM.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.42.42%20PM.png)

In the full model, Fielding Runs Above Average, Runs From Extra Strikes, Blocking Runs, and Strike Rate in Zone 14 has a p-value below 0.05 making it a statistically significant. FRAA being in this list does not come as a surprise since most of the CDA is attributed to Fielding Runs Above Average.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/unnamed-chunk-13-1.png)

Most of the coefficients in the full model are on a similar scale as the simple linear regression coefficients with the exception of Exchange, Pop Time, and Fielding Runs Above Average.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/unnamed-chunk-14-1.png)

There were some major differences between the SLR and Full model for Strike Rates in Zones 17, 18, and 19. In addition, the same thing occurred with Blocking Runs (EPAA Runs), Strike Rate, and Runs From Extra Strikes. Strike Rate actually differed in signs as Strike Rate was positive in SLR and negative in the full.

I also looked for evidence of non-linear associations using cubic regression model.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.42.30%20PM.png)

For five features (Pop Time, Strike Rate, Strike Rate in Zone 18, Strike Rate in Zone 19, and Runs From Extra Strikes), an ANOVA test showed that the fits for these features’ cubic model fits were significantly improved over the linear models.The small p-values indicate that there is little evidence to support the null hypothesis that the SLR models fit equally as well as the cubic models. There is evidence of non-linear association between CDA and predictors.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.15.41%20PM.png)

A linear model including all predictors explains about 93.5% of the variance in Catcher Defensive Adjustment with a small test MSE. A linear model including only Runs From Extra Strikes explains about 64.4% of the variance in Catcher Defensive Adjustment with a large MSE.

### Ridge Regression

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/RidgeReg.png)

### Lasso

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Lasso.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.15.50%20PM.png)

lasso_min seemed to explain 94% of the variance in Catcher Defensive Adjustment using all the variables and had the lowest test MSE. ridge_min, ridge_1se, and lasso_1se in that order with similar numbers ranging from 92.6% to 93.7% of the variance explained and 3.16 to 3.73 in test MSE.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.16.00%20PM.png)

Both lasso models retained Runs From Extra Strikes which is encouraging for the notion that it could replace CSAA. As expected, FRAA remained in all four models as it is a key component of the Catcher Defensive Adjustment formula.

### Best Subset Selection

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.16.08%20PM.png)

The best subset selection model included three variables which definitely includes Fielding Runs Above Average with a test MSE lower than the linear model and higher than lasso/ridge models.

### PCR and PLS

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/PCR.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/PLS.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.56.00%20PM.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/FRAA.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/FRAA%20MSEP.png)

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%208.17.02%20PM.png)

The PCR model with 13 components seemed to perform the best out of the two types of models in this section. It had a test MSE similar to the previous models in the report and same as the linear regression model. The PLS model with 5 components did not perform well compared to the rest at about a test MSE of about 11.

## Conclusion
The final model was selected when accounting for the lowest test mean squared error and the highest proportion of the variance in CDA explained. The lasso_min model performed the best out of the models chosen resulting in a test mean squared error of 3.16 and a proportion of 93.7% of the variance in CDA explained. The model also retained Runs From Extra Strikes which could possibly prove that this metric from Statcast can replace the metric from Baseball Prospectus for a more accurate version when predicting catcher’s overall defense. In addition, it also kept Strike Rate, Blocking Runs, and Strike Zones 14 and 16.

Framing is an integral part of evaluating the quality of a catcher’s defense and to have a better understanding when comparing catchers. Statcast providing state-of-art technology is a plus that allows baseball analysts to further their studies when it comes to defense, a difficult avenue to quanitfy in the game of baseball. What we can do to improve these metrics is to keep adding data from this season (hopefully there is a season) and the ones to come as Statcast is simultaneously improving as well as the statistics I covered in this project. Other entities such as FanGraphs and Baseball have new, specific metrics for catchers that could be potential variables for the dataset. Lastly, another model I could have used was Polynomial Regression and could have used Cross-Validation and Validation

## Appendix

### Exploratory Data Analysis
My initial step to explore the dataset was to skim through the variables using skim_without_charts.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Screen%20Shot%202020-09-18%20at%209.00.22%20PM.png)

Although it may not be the MLB average velocity for catchers throwing to 2nd base, it was surprising to see that the average velocity of this EDA set was 81.5 MPH. Catcher’s arms range from the mid-70s to the high 80s which explains part of the trade-offs teams have to deal with. Some catchers may have weaker arms but can frame pitches better or hit the ball better.

This particular group of catchers seemed to have high percentages when it came to getting the call for pitches in zones 14 and 16. It also seemed to be able to prevent runs from scoring due to wild pitches and passed balls. Definitely a superb framing group since the average was 2.67 for Runs from Extra Strikes. Pop Time and Exchange times were average by MLB standards.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/CORR.png)

Strike Rate seems to have a strong positive relationship with the bottom of the Shadow Zone (16-19). This could signal that framing low pitches is a major factor in determining your overall strike rate. Strike Rate, as stated previously is a cumulative total percentage based on the Shadow Zone percentages. Although some zones tend to correlate slightly positive with the overall metric, they are weak signs of multicollinearity meaning a particular zone cannot predict the overall strike rate.

As expected, max effort velocity to 2nd or 3rd base shares a negative relationship with Pop Time because the faster you throw the less time it takes for the baseball to reach the receiver. Max effort velocity also seems to have a slight positive relationship with our overall defensive measure, fraa_adj and fielding runs above average. It is easier to get people out on bunts and plays to every base if you have a strong arm.

Exchange shares a solid positive relationship with max efforts velocity implying that catchers with higher velocities tend to have longer exchange times in seconds. One idea that came about when observing this is that players with strong arms that can reach higher velocities probably take a longer time transfering the baseball from their glove to a more comfortable throwing position to produce a stronger throw. In the meanwhile, it could be the case that catchers with slower velocities tend to release the ball quicker in order to have a chance at catching the runner.

Runs from Extra Strikes has a robust relationship with both fraa_adj and fraa. This is encouraging to see since the Statcast metric is replacing Called Strikes Above Average from Baseball Prospectus. The higher this metric is, the higher the value as a catcher in overall defense.

Blocking Runs seems to have very few notable relationships with the other variables.However, the correlation plot shows a strong positive relationship with fraa_adj and fraa. The more passed balls and wild pitches you prevent, the higher your value on defense is a possible conclusion to that finding.

According to the correlation plot, maxeff_arm_2b_3b_sba has a negative relationship with pop time to second base. The regression line seems to veer off in the middle of the cluster. I assume that although these catchers have around the same velocity to the bases, they differ in exchange time.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/Maxeffarm.png)

Since Blocking Runs was the other component from the Catcher Defensive Adjustment formula, I wanted to isolate the metric and regress it on fraa_adj. Most of the points seem to be clustered between -1.5 and 2. The outliers on both ends being removed could prove that the more runs a catcher prevents through blocking wild pitches and avoiding passed balls adds somewhat significant value to overall defense.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/epaa_runs.png)

These two clearly share a strong positive relationship and seems that it could be stronger when removing a couple of points far away from the majority. The more runs you save from framing pitches and giving your pitchers more opportunities for outs, the more your overall defensive value increases.

![alt text](https://github.com/HugoBelisario/CatcherDefense/blob/master/Visualizations/runs_from_extra_strikes.png)


