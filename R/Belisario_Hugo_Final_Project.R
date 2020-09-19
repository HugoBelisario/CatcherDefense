# Final Project -----------------------------------------------------------

# Hugo Belisario

# STAT 301-2 Data Science

# 17 March 2020

# Catcher Defense during the Statcast Era

# Data Scope and Identification -------------------------------------------

# The datasets used for this Final Project came from Baseball Prospectus (BP), an organization that runs a website devoted to sabermetric analysis of baseball, and BaseballSavant, a site dedicated to providing player matchups, Statcast metrics, and advanced statistics in a simple and easy-to-view way.
# Baseball Prospectus recently built a new Leaderboards platform that is currently in Beta and includes Hitting, Pitching, and Catcher Defense Leaderboards.
# BP has their own way of calculating an overall defensive measure for catchers called Catcher Defensive Adjustment or Fielding Runs Above Average Adjustment.
# However, they do not possess Statcast metrics for other aspects of the position besides traditional fielding such as pitch framing, pop time, and exchange.
# BaseballSavant maintains Statcast Leaderboards for Catcher Pop Time and Catcher Framing.


# The question of interest is the following: Can we predict a catcher's overall defensive value using Statcast data to replace metrics used by Baseball Prospectus?
# The notion behind my curiosity is that since Statcast is the state-of-the-art tracking technology implemented by the MLB then it must serve as a more accurate way of predicting a catcher's defensive performance than third-party organizations.
# Statcast and Baseball Savant do not provide an overall defensive measure for catchers, but BP does.
# Hence, I believe that although there are similarities to statistics provided by both entities using Statcast data can give us more insight as to how these catcher's have actually performed utilizing BP's formula for Catcher Defense Adjustment.
# This project is regression-based since I am working with continuous variables.

# Background ------------------------------------------------------------

# Catcher's influence on defense is more subtle than the other positions in baseball.
# You cannot judge a catcher's defensive performance based on their number of steals allowed or their caught stealing rate because the pitcher and runner play important parts in determining the probability of a steal attempt, let alone a successful one.
# Just like your typical fielders, catchers need to put tags on runners trying to score, field bunts, and chase pop flies.

# However, baseball is a game of inches.
# Any small advantage or edge that teams can improve upon or add to their organization, they will try to maximize it.
# Framing and Pop Time/Exchange are those tools that could win a team ballgames, postseason berths, and titles.
# A significant component of a catcher's skillset is the ability to prevent runners from advancing and scoring on wild pitches and passed balls by blocking.
# The best way to prevent a steal is to prevent the runner from attempting it.
# Pop Time measures the time from the moment the pitch hits the catcher’s mitt to the moment the ball reaches the fielder’s projected receiving point at the center of the base. 
# Pop Time is a combination of exchange time (how quickly the catcher releases the ball, measured in seconds) and arm strength (velocity of throw, in MPH).

# Pitch framing for catchers involves receiving the ball and catching it in a manner that favors the pitcher with a strike located outside of standard zones, but in the specific umpire's zone.
# Catcher framing is the art of a catcher receiving a pitch in a way that makes it more likely for an umpire to call it a strike.
# Baseball Savant breaks down the catcher’s view into eight zones around the strike zone and shows the called strike percentage of all non-swings in that zone.
# Framing stats measure how many runs catchers save based on how many extra strikes they provide for their pitchers.

# Main driver of overall defense, following metrics are additions to the contributions of a catcher, nonetheless they are still valuable.
# FRAA, Fielding Runs Above Average, traditional fielding ability (i.e. bunts, pop flies)
# CSAA, Called Strikes Above Average, is how BP measures a catcher’s ability to frame pitches.
# CSAA Runs provides a run value for called strikes due to framing.
# EPAA, Errant Pitches Above Average, measures a catcher’s ability to block wild pitches and prevent passed balls.
# SRAA, Swipe Rate Above Average, calculates a catcher’s ability to throw runners out
# TRAA, Takeoff Rate Above Average, stolen base attempts above league average.
# PORAA, Pick Off Runs Above Average, places run value on pick offs. 

# Baseball Prospectus calculates their overall defensive measure by adding Framing Runs (CSAA Runs), Blocking Runs (EPAA Runs), and Throwing Runs (SRAA Runs + TRAA Runs + PORAA Runs) to Fielding Runs Above Average (FRAA).
# However, as stated above I want to replace CSAA with Runs From Extra Strikes while also observing the relationships and impact other Statcast metrics such as Strike Rates, Pop Times, and Exchange times have on CDA.

# Load Packages -----------------------------------------------------------

library(tidyverse)
library(janitor)
library(skimr)
library(corrplot)
library(broom)
library(modelr)
library(ggfortify)
library(knitr)
library(GGally)
library(rsample)
library(leaps) # best subset selection
library(glmnet) # ridge & lasso
library(glmnetUtils) # improves working with glmnet
library(pls)

# set seed
set.seed(3)

# Baseball Prospectus Catcher Defense -----------------------------------------------------

# Statcast tracking technology was set up in all 30 stadiums starting in 2015. 
# For that reason, I am only using seasonal data since 2015 for this project.
# After reading in the Baseball Prospectus .csv files from 2015-2019, I proceeded to remove some unneccesary variables and create a 'year' variable for the dataset.
# The 'year' variable was later used to join datasets.
# The same process is completed for all of the seasons.

# 2019
bp_catchers_2019 <- read_csv("data/bpcatchers2019.csv") %>%
  clean_names() %>%
  # remove playerid, version_date, team, lg since they are not important variables in my analysis
  select(-playerid, -version_date, team, lg) %>%
  mutate(year = 2019)

# separate name column into two columns, first_name and last_name.
bp_catchers_2019 <- extract(bp_catchers_2019, name, c("first_name", "last_name"), "([^ ]+) (.*)")

bp_catchers_2019 <- bp_catchers_2019 %>%
  # ordering the data by making names and year the first two columns makes it easier for the final dataset
  select(first_name, last_name, year, everything())

# 2018
bp_catchers_2018 <- read_csv("data/bpcatchers2018.csv") %>%
  clean_names() %>%
  select(-playerid, -version_date, team, lg) %>%
  mutate(year = 2018) 

bp_catchers_2018 <- extract(bp_catchers_2018, name, c("first_name", "last_name"), "([^ ]+) (.*)")
bp_catchers_2018 <- bp_catchers_2018 %>%
  select(first_name, last_name, year, everything())

# 2017
bp_catchers_2017<- read_csv("data/bpcatchers2017.csv") %>%
  clean_names() %>%
  select(-playerid, -version_date, team, lg) %>%
  mutate(year = 2017)

bp_catchers_2017 <- extract(bp_catchers_2017, name, c("first_name", "last_name"), "([^ ]+) (.*)")
bp_catchers_2017 <- bp_catchers_2017 %>%
  select(first_name, last_name, year, everything())

# 2016
bp_catchers_2016 <- read_csv("data/bpcatchers2016.csv") %>%
  clean_names() %>%
  select(-playerid, -version_date, team, lg) %>%
  mutate(year = 2016)

bp_catchers_2016 <- extract(bp_catchers_2016, name, c("first_name", "last_name"), "([^ ]+) (.*)")
bp_catchers_2016 <- bp_catchers_2016 %>%
  select(first_name, last_name, year, everything())

# 2015
bp_catchers_2015 <- read_csv("data/bpcatchers2015.csv") %>%
  clean_names() %>%
  select(-playerid, -version_date, team, lg) %>%
  mutate(year = 2015)

bp_catchers_2015 <- extract(bp_catchers_2015, name, c("first_name", "last_name"), "([^ ]+) (.*)")
bp_catchers_2015 <- bp_catchers_2015 %>%
  select(first_name, last_name, year, everything())

# add rows from each dataframe together and formed bp_catchers using rbinds
bp_catchers <- rbind(bp_catchers_2015, bp_catchers_2016, bp_catchers_2017, bp_catchers_2018, bp_catchers_2019)

# arrange the names and age so that players with multiple appearances in the featured years have their rows in order of age
bp_catchers <- bp_catchers %>%
  arrange(first_name, last_name, age)

# Baseball Savant Statcast Catcher Framing ------------------------------------------------

# Similar to the previous set of data, I removed unnecessary variables that could have potentially caused trouble when analyzing the data.
# The Catcher Framing dataset included an MLB average of all the metrics as the first row, this was consequently removed.
# Later on, I added the rows together and arranged them by name of the player.

# 2019
catcher_framing_2019 <- read_csv("data/catcher-framing2019.csv") %>%
  clean_names() %>%
  # remove fielder_2 similar to playerid in Baseball Prospectus dataset
  select(-fielder_2) %>%
  # order by name
  select(first_name, last_name, everything())

# remove first row
catcher_framing_2019 <- catcher_framing_2019[-1, ]

# 2018
catcher_framing_2018 <- read_csv("data/catcher-framing2018.csv") %>%
  clean_names() %>%
  select(-fielder_2) %>%
  select(first_name, last_name, everything())

# remove first row
catcher_framing_2018 <- catcher_framing_2018[-1, ]

# 2017
catcher_framing_2017 <- read_csv("data/catcher-framing2017.csv") %>%
  clean_names() %>%
  select(-fielder_2) %>%
  select(first_name, last_name, everything())

# remove first row
catcher_framing_2017 <- catcher_framing_2017[-1, ]

# 2016
catcher_framing_2016 <- read_csv("data/catcher-framing2016.csv") %>%
  clean_names() %>%
  select(-fielder_2) %>%
  select(first_name, last_name, everything())

# remove first row
catcher_framing_2016 <- catcher_framing_2016[-1, ]

# 2015
catcher_framing_2015 <- read_csv("data/catcher-framing2015.csv") %>%
  clean_names() %>%
  select(-fielder_2) %>%
  select(first_name, last_name, everything())

# remove first row
catcher_framing_2015 <- catcher_framing_2015[-1, ]

# combine all five datasets to form one, using rbinds to add the rows
catcher_framing <- rbind(catcher_framing_2015, catcher_framing_2016, catcher_framing_2017, catcher_framing_2018, catcher_framing_2019)

# arrange by name
catcher_framing <- catcher_framing %>% 
  arrange(first_name, last_name) 

# Statcast Catcher Pop Time and Exchange ----------------------------------

# The dataset for Pop Time and Exchange was the most complicated to configure into one that could smoothly join the rest.
# Below each command, I explain it's purpose as it pertains to forming the final dataset.

# 2019
catcher_poptime_2019 <- read_csv("data/poptime2019.csv") %>%
  clean_names() %>%
  # column for player names is called catcher
  rename(name = catcher) %>%
  # player_id and team_id are useless for this analysis
  select(-player_id, -team_id) %>%
  # add year to join poptime with framing data
  mutate(year = 2019) %>%
  # arrange columns to show age and year
  select(name, age, year, everything())

# Separate name column into two columns, first_name and last_name.
catcher_poptime_2019 <- extract(catcher_poptime_2019, name, c("first_name", "last_name"), "([^ ]+) (.*)")

# Use inner_join to unite both Baseball Savant Catching Leaderboards into one dataframe using keys name and year.
catchers_statcast_2019 <- catcher_poptime_2019 %>% 
  inner_join(catcher_framing_2019, by = c("first_name", "last_name", "year"))

# 2018
catcher_poptime_2018 <- read_csv("data/poptime2018.csv") %>%
  clean_names() %>%
  rename(name = catcher) %>%
  select(-player_id, -team_id) %>%
  mutate(year = 2018) %>%
  select(name, age, year, everything())

catcher_poptime_2018 <- extract(catcher_poptime_2018, name, c("first_name", "last_name"), "([^ ]+) (.*)")

catchers_statcast_2018 <- catcher_poptime_2018 %>% 
  inner_join(catcher_framing_2018, by = c("first_name", "last_name", "year"))

# 2017
catcher_poptime_2017 <- read_csv("data/poptime2017.csv") %>%
  clean_names() %>%
  rename(name = catcher) %>%
  select(-player_id, -team_id) %>%
  mutate(year = 2017) %>%
  select(name, age, year, everything())

catcher_poptime_2017 <- extract(catcher_poptime_2017, name, c("first_name", "last_name"), "([^ ]+) (.*)")

catchers_statcast_2017 <- catcher_poptime_2017 %>% 
  inner_join(catcher_framing_2017, by = c("first_name", "last_name", "year"))

# 2016
catcher_poptime_2016 <- read_csv("data/poptime2016.csv") %>%
  clean_names() %>%
  rename(name = catcher) %>%
  select(-player_id, -team_id) %>%
  mutate(year = 2016) %>%
  select(name, age, year, everything())

catcher_poptime_2016 <- extract(catcher_poptime_2016, name, c("first_name", "last_name"), "([^ ]+) (.*)")

catchers_statcast_2016 <- catcher_poptime_2016 %>% 
  inner_join(catcher_framing_2016, by = c("first_name", "last_name", "year"))

# 2015
catcher_poptime_2015 <- read_csv("data/poptime2015.csv") %>%
  clean_names() %>%
  rename(name = catcher) %>%
  select(-player_id, -team_id) %>%
  mutate(year = 2015) %>%
  select(name, age, year, everything())

catcher_poptime_2015 <- extract(catcher_poptime_2015, name, c("first_name", "last_name"), "([^ ]+) (.*)")

catchers_statcast_2015 <- catcher_poptime_2015 %>% 
  inner_join(catcher_framing_2015, by = c("first_name", "last_name", "year"))

# combine all five datasets to form one that represents the metrics provided by Statcast
catchers_statcast <- rbind(catchers_statcast_2015, catchers_statcast_2016, catchers_statcast_2017, catchers_statcast_2018, catchers_statcast_2019)

catchers_statcast <- catchers_statcast %>%
  arrange(first_name, last_name, age)

# join the Statcast and Baseball Prospectus datasets
catchers <- catchers_statcast %>% 
  inner_join(bp_catchers, by = c("first_name", "last_name", "year"))

# Clean Final Dataset -----------------------------------------------------

# remove lg since league is not an important variable in the dataset and age.y is a repeat of the age column 
catchers <- catchers %>%
  select(-lg, -age.y) %>%
  select(first_name, last_name, age.x, year, team, everything())

# rename age.x to just "age"
catchers <- rename(catchers, age = age.x)

# remove name, team to avoid any problems with model building
# remove pop time to second base metrics since they produce question marks in the results when running corrplots() and models.
# remove throwing runs, framing runs since we are replacing those with Statcast data for those.
catchers <- catchers %>%
  select(-c(first_name, last_name, team, age, year, pop_3b_sba_count, po_runs, epaa_chances, epaa, n_called_pitches, pop_2b_cs, pop_2b_sb, pop_2b_sba_count, pop_3b_sba, pop_3b_cs, pop_3b_sb, csaa_runs, csaa, csaa_chances, csaa_sd, csaa_runs_sd, sraa, sraa_chances, traa, traa_runs, po_chances))

# By the end of this cleaning, the dataset contains 505 observations and 16 variables. 

catchers <- catchers %>%
  na.omit

# When ommiting NA values from the dataset (mostly from missing numbers for pop time to second base), the dataset is left with 481 observations.
# This means that there were 24 missing values.

# Codebook ----------------------------------------------------------------

# maxeff_arm_2b_3b_sba: arm strength measured on "max effort" throws, or the average above a player's 90th percentile performance, in miles per hour (MPH)
# exchange_2b_3b_sba: exchange time measured in seconds
# pop_2b_sba: pop time to second base in seconds           
# runs_extra_strikes: strikes to runs saved on a .125 run/strike basis, and includes park and pitcher adjustments
# strike_rat: cumulative total of all zones, percentages of called strikes from pitches that were not swung at in zones 11-17.
# strike_rate_11: percentages of called strikes from all called pitches in zone 11       
# strike_rate_12: percentages of called strikes from all called pitches in zone 12    
# strike_rate_13: percentages of called strikes from all called pitches in zone 13
# strike_rate_14: percentages of called strikes from all called pitches in zone 14
# strike_rate_16: percentages of called strikes from all called pitches in zone 16
# strike_rate_17: percentages of called strikes from all called pitches in zone 17
# strike_rate_18: percentages of called strikes from all called pitches in zone 18
# strike_rate_19: percentages of called strikes from all called pitches in zone 19       
# fraa_adj: catcher defensive adjustment or fielding runs above average adjustment            
# fraa: fielding runs above average               
# epaa_runs: errant pitches above average also known as blocking runs

# The First Random Data Split -----------------------------------------------

# The data is not very large which led me to use two data splits.
# My first split provided 48 observations to run some EDA methods.

# split data for EDA and modeling sets, 10% for EDA and 90% for modeling
catchers_eda_set <- catchers %>% 
  sample_frac(0.1)

catchers_modeling_data <- catchers %>%
  setdiff(catchers_eda_set)

# Exploratory Data Analysis -----------------------------------------------

# My initial step to explore the dataset was to skim through the variables using skim_without_charts.
catchers_eda_set %>% 
  skim_without_charts()

# Although it may not be the MLB average velocity for catchers throwing to 2nd base, it was surprising to see that the average velocity of this EDA set was 81.5 MPH.
# Catcher's arms range from the mid-70s to the high 80s which explains part of the trade-offs teams have to deal with.
# Some catchers may have weaker arms but can frame pitches better or hit the ball better.

# This particular group of catchers seemed to have high percentages when it came to getting the call for pitches in zones 14 and 16.
# It also seemed to be able to prevent runs from scoring due to wild pitches and passed balls.
# Definitely a superb framing group since the average was 2.67 for Runs from Extra Strikes.
# Pop Time and Exchange times were average by MLB standards.

catchers_eda_set %>%
  cor() %>%
  corrplot::corrplot()

# Strike Rate seems to have a strong positive relationship with the bottom of the Shadow Zone (16-19). 
# This could signal that framing low pitches is a major factor in determining your overall strike rate.
# Strike Rate, as stated previously is a cumulative total percentage based on the Shadow Zone percentages.
# Although some zones tend to correlate slightly positive with the overall metric, they are weak signs of multicollinearity meaning a particular zone cannot predict the overall strike rate.

# As expected, max effort velocity to 2nd or 3rd base shares a negative relationship with Pop Time because the faster you throw the less time it takes for the baseball to reach the receiver.
# Max effort velocity also seems to have a slight positive relationship with our overall defensive measure, fraa_adj and fielding runs above average.
# It is easier to get people out on bunts and plays to every base if you have a strong arm.

# Exchange shares a solid positive relationship with max efforts velocity implying that catchers with higher velocities tend to have longer exchange times in seconds.
# One idea that came about when observing this is that players with strong arms that can reach higher velocities probably take a longer time transfering the baseball from their glove to a more comfortable throwing position to produce a stronger throw.
# In the meanwhile, it could be the case that catchers with slower velocities tend to release the ball quicker in order to have a chance at catching the runner.

# Runs from Extra Strikes has a robust relationship with both fraa_adj and fraa.
# This is encouraging to see since the Statcast metric is replacing Called Strikes Above Average from Baseball Prospectus.
# The higher this metric is, the higher the value as a catcher in overall defense.

# Blocking Runs seems to have very few notable relationships with the other variables.
# However, the correlation plot shows a strong positive relationship with fraa_adj and fraa.
# The more passed balls and wild pitches you prevent, the higher your value on defense is a possible conclusion to that finding.

# According to the correlation plot, maxeff_arm_2b_3b_sba has a negative relationship with pop time to second base.
# The regression line seems to veer off in the middle of the cluster.
# I assume that although these catchers have around the same velocity to the bases, they differ in exchange time.
ggplot(data = catchers_eda_set, mapping = aes(x = maxeff_arm_2b_3b_sba, y = pop_2b_sba)) + 
  geom_point() +
  geom_smooth(se = FALSE)

# Since Blocking Runs was the other component from the Catcher Defensive Adjustment formula, I wanted to isolate the metric and regress it on fraa_adj.
# Most of the points seem to be clustered between -1.5 and 2.
# The outliers on both ends being removed could prove that the more runs a catcher prevents through blocking wild pitches and avoiding passed balls adds somewhat significant value to overall defense.
ggplot(data = catchers_eda_set, mapping = aes(x = epaa_runs, y = fraa_adj)) + 
  geom_point() +
  geom_smooth(se = FALSE)

# These two clearly share a strong positive relationship and seems that it could be stronger when removing a couple of points far away from the majority.
# The more runs you save from framing pitches and giving your pitchers more opportunities for outs, the more your overall defensive value increases.
ggplot(data = catchers_eda_set, mapping = aes(x = runs_extra_strikes, y = fraa_adj)) + 
  geom_point() +
  geom_smooth(se = FALSE)

# The Second Random Data Split (Splitting Analysis Dataset) ---------------

# Since the dataset was not large, I chose to perform a second random data split in order to attain more accurate predictive results.
# Chose to split the data 60%-40% for comparing candidate models and model building, respetively.

# Test set for comparing candidate models, selecting final model
catchers_mod_comp_dat <- catchers_modeling_data %>% sample_frac(0.60)

# Train set for candidate model building
catchers_mod_bldg_dat <- catchers_modeling_data %>% setdiff(catchers_mod_comp_dat)

# Simple Linear Regression ------------------------------------------------

# Setup formulas for simple linear regressions
predictor_var <- catchers_mod_bldg_dat %>% names() %>% setdiff("fraa_adj")
fmla <- paste("fraa_adj ~", predictor_var)

# adding full model
predictor_var <- c(predictor_var, "all_vars")
fmla <- c(fmla, "fraa_adj ~ .")

# Fit and store the models
catchers_models <- tibble(
  data = list(catchers_mod_bldg_dat), 
  predictor_var, 
  fmla
) %>% 
  mutate(model_fit = map2(fmla, data, lm),
         model_type = if_else(predictor_var == "all_vars", "full", "slr"))

# Model fit summaries/information
catchers_models <- catchers_models %>% 
  mutate(mod_glance  = map(model_fit, glance),
         mod_tidy    = map(model_fit, tidy),
         add_tidy    = map(model_fit, confint_tidy),
         mod_tidy    = map2(mod_tidy, add_tidy, bind_cols),
         mod_augment = map2(model_fit, data, augment)) %>%
  select(-add_tidy)

# Models in which there is a statistically significant association between the predictor and the response.
catchers_models %>% 
  unnest(mod_tidy) %>% 
  filter(model_type != "full", term != "(Intercept)") %>% 
  select(term, estimate, p.value) %>% 
  arrange(p.value) %>%
  filter(p.value < 0.05)

# Fielding Runs Above Average, Runs From Extra Strikes, Strike Rate, Strike Rate in Zone 18, Blocking Runs, Strike Rate in Zone 19, Strike Rate in Zone 17, and Strike Rate in Zone 16 had statistically significant estimates.

# Plotting investigating linear relationship with FRAA_ADJ/CDA.
catchers_mod_bldg_dat %>% 
  pivot_longer(cols = -fraa_adj, names_to = "predictor", values_to = "value") %>% 
  ggplot(aes(x = value, y = fraa_adj)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  coord_cartesian(ylim = c(0, 25)) +
  facet_wrap(. ~ predictor, scales = "free_x")

# A table that details the relationship between all of the variables and Catcher Defensive Adjustment in scatterplots with linear regression lines.

# Investigating full model
catchers_models %>% 
  filter(model_type == "full") %>% 
  unnest(mod_tidy) %>% 
  select(-predictor_var, -fmla, -model_type)

# Identify significant slope/linear parameters in full model
catchers_models %>% 
  unnest(mod_tidy) %>% 
  filter(model_type == "full", term != "(Intercept)") %>% 
  select(term, estimate, p.value) %>% 
  arrange(p.value) %>% 
  filter(p.value < 0.05)

# In the full model, Fielding Runs Above Average, Runs From Extra Strikes, Blocking Runs, and Strike Rate in Zone 14 has a p-value below 0.05 making it a statistically significant.
# FRAA being in this list does not come as a surprise since most of the CDA is attributed to Fielding Runs Above Average.

# Scatterplot to compare SLR to Full estimates
catchers_models %>% 
  unnest(mod_tidy) %>%
  filter(term != "(Intercept)") %>% 
  select(model_type, term, estimate) %>% 
  pivot_wider(names_from = model_type, values_from = estimate) %>% 
  ggplot(aes(full, slr)) +
  geom_point() +
  geom_abline(color = "blue", linetype = "dashed")

# Most of the coefficients in the full model are on a similar scale as the simple linear regression coefficients with the exception of Exchange, Pop Time, and Fielding Runs Above Average.

# Alternative to scatterplot, a plot of paired confidence intervals for each of the predictors.
catchers_models %>% 
  unnest(mod_tidy) %>% 
  filter(term != "(Intercept)") %>% 
  ggplot(aes(model_type, estimate)) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  facet_wrap(. ~ term, scales = "free_x") +
  coord_flip()

# There were some major differences between the SLR and Full model for Strike Rates in Zones 17, 18, and 19.
# In addition, the same thing occurred with Blocking Runs (EPAA Runs), Strike Rate, and Runs From Extra Strikes.
# Strike Rate actually differed in signs as Strike Rate was positive in SLR and negative in the full.

# Looking for evidence of non-linear associations using cubic regression model.

# Setup formulas for cubic models
predictor_var <- catchers_mod_bldg_dat %>% names() %>% setdiff(c("fraa_adj"))
fmla <- paste0("fraa_adj ~ poly(", predictor_var, ", 3)")

# Fit and store the cubic models
cubic_models <- tibble(
  data = list(catchers_mod_bldg_dat), 
  predictor_var, 
  fmla
) %>% 
  mutate(cubic_fit = map2(fmla, data, lm)) 

catchers_models %>% 
  # drop full model from model database
  filter(model_type != "full") %>% 
  select(predictor_var, model_fit) %>% 
    # join catchers model database with new cubic models
  left_join(cubic_models, by ="predictor_var") %>% 
  # add comparison column linear vs cubic fits
  mutate(anova_test = map2(model_fit, cubic_fit, anova)) %>% 
  # unwrap anova results - h_0: submodel does just as well as larger
  unnest(anova_test) %>% 
  # p-value is really prob F RV bigger than observed F
  drop_na() %>% 
  # p-value is really prob F RV bigger than observed F stat
  rename(term = predictor_var, p_value = `Pr(>F)`) %>% 
  select(term, p_value) %>% 
  filter(p_value < 0.05) %>% 
  arrange(p_value)

# For five features (Pop Time, Strike Rate, Strike Rate in Zone 18, Strike Rate in Zone 19, and Runs From Extra Strikes), an ANOVA test showed that the fits for these features’ cubic model fits were significantly improved over the linear models.
# The small p-values indicate that there is little evidence to support the null hypothesis that the SLR models fit equally as well as the cubic models.
# There is evidence of non-linear association between crime rate and predictors.

# Same split, just in different format for this part of the Linear Regression model analysis
catchers_split <- tibble(
  catchers_mod_comp_dat = catchers_modeling_data %>% 
    sample_frac(0.60) %>% 
    list(),
  catchers_mod_bldg_dat = catchers_modeling_data %>% 
    setdiff(catchers_mod_comp_dat) %>% 
    list()) 

pred_variables <- names(catchers_mod_bldg_dat) %>% 
  setdiff(c("fraa_adj"))

lm_models <- tibble(fmla = c(str_c("fraa_adj ~ ", str_c(pred_variables, collapse = " + ")), 
                             "fraa_adj ~ runs_extra_strikes"),
                    model_name = c("all_vars", "runs_extra_strikes")) %>% 
  mutate(fmla = map(fmla, as.formula))

test_catchers_var <- catchers_split %>% 
  pluck("catchers_mod_bldg_dat", 1, "fraa_adj") %>% 
  var()

catchers_lm_fits <- catchers_split %>% 
  crossing(lm_models) %>% 
  mutate(
    model_fit = map2(fmla, catchers_mod_comp_dat, lm),
    test_mse = map2_dbl(model_fit, catchers_mod_bldg_dat, modelr::mse),
    prop_var_explained = 1 - (test_mse/test_catchers_var)
  )

catchers_lm_fits %>% 
  select(model_name, test_mse, prop_var_explained) %>% 
  arrange(test_mse)

# A linear model including all predictors explains about 93.5% of the variance in Catcher Defensive Adjustment with a small test MSE
# A linear model including only Runs From Extra Strikes explains about 64.4% of the variance in Catcher Defensive Adjustment with a large MSE.

# Linear Model Selection and Regularization -------------------------------

# Ridge Regression --------------------------------------------------------

# Figure out variance of outcome variable; will be useful later.
test_fraa_adj_var <- catchers_split %>% 
  pluck("catchers_mod_bldg_dat", 1, "fraa_adj") %>% 
  var()

# lambda grid to search -- use for ridge regression (200 values)
lambda_grid <- 10^seq(-2, 10, length = 200)

# ridge regression: 10-fold cv
ridge_cv <- catchers_mod_bldg_dat %>% 
  cv.glmnet(
    formula = fraa_adj ~ ., 
    data = ., 
    alpha = 0, 
    nfolds = 10,
    lambda = lambda_grid
  )

# Check plot of cv error
plot(ridge_cv)

# ridge's best lambdas
ridge_lambda_min <- ridge_cv$lambda.min
ridge_lambda_1se <- ridge_cv$lambda.1se

# Lasso  ------------------------------------------------------------------

# lasso: 10-fold cv
lasso_cv <- catchers_mod_bldg_dat %>% 
  cv.glmnet(
    formula = fraa_adj ~ ., 
    data = ., 
    alpha = 1, 
    nfolds = 10
  )

# Check plot of cv error
plot(lasso_cv)

# lasso's best lambdas
lasso_lambda_1se <- lasso_cv$lambda.1se
lasso_lambda_min <- lasso_cv$lambda.min

catchers_glmnet <- catchers_split %>%
  mutate(
    ridge_min = map(catchers_mod_comp_dat, ~ glmnet(fraa_adj ~ ., data = .x,
                                                    alpha = 0, lambda = ridge_lambda_min)),
    ridge_1se = map(catchers_mod_comp_dat, ~ glmnet(fraa_adj ~ ., data = .x,
                                                    alpha = 0, lambda = ridge_lambda_1se)),
    lasso_min = map(catchers_mod_comp_dat, ~ glmnet(fraa_adj ~ ., data = .x,
                                                    alpha = 1, lambda = lasso_lambda_min)),
    lasso_1se = map(catchers_mod_comp_dat, ~ glmnet(fraa_adj ~ ., data = .x,
                                                    alpha = 1, lambda = lasso_lambda_1se))
  ) %>% 
  pivot_longer(cols = c(-catchers_mod_bldg_dat, -catchers_mod_comp_dat), names_to = "method", values_to = "fit")

# Test error and R squared for ridge and lasso fits
catchers_glmnet_error <- catchers_glmnet %>% 
  mutate(pred = map2(fit, catchers_mod_bldg_dat, predict),
         test_mse = map2_dbl(catchers_mod_bldg_dat, pred, ~ mean((.x$fraa_adj - .y)^2))) %>% 
  unnest(test_mse) %>% 
  select(method, test_mse) %>% 
  mutate(prop_explained = 1 - test_mse/test_fraa_adj_var) %>% 
  arrange(test_mse)

catchers_glmnet_error

# lasso_min seemed to explain 94% of the variance in Catcher Defensive Adjustment using all the variables and had the lowest test MSE.
# ridge_min, ridge_1se, and lasso_1se in that order with similar numbers ranging from 92.6% to 93.7% of the variance explained and 3.16 to 3.73 in test MSE.

# Inspect/compare model coefficients 
catchers_glmnet %>% 
  pluck("fit") %>% 
  map( ~ coef(.x) %>% 
         as.matrix() %>% 
         as.data.frame() %>% 
         rownames_to_column("name")) %>%
  reduce(full_join, by = "name") %>% 
  mutate_if(is.double, ~ if_else(. == 0, NA_real_, .)) %>% 
  rename(ridge_min = s0.x,
         ridge_1se = s0.y,
         lasso_min = s0.x.x,
         lasso_1se = s0.y.y) %>% 
  knitr::kable(digits = 3)

# Both lasso models retained Runs From Extra Strikes which is encouraging for the notion that it could replace CSAA.
# As expected, FRAA remained in all four models as it is a key component of the Catcher Defensive Adjustment formula.

# Best Subset Selection ---------------------------------------------------

# Helper Functions
predict_regsubset <- function(object, fmla , new_data, model_id)
{
  if(!is.data.frame(new_data)){
    new_data <- as_tibble(new_data)
  }
  obj_formula <- as.formula(fmla)  
  coef_vector <- coef(object, model_id)  
  x_vars <- names(coef_vector)
  mod_mat_new <- model.matrix(obj_formula, new_data)[ , x_vars]  
  pred <- as.numeric(mod_mat_new %*% coef_vector)
  return(pred)
}

test_mse_regsubset <- function(object, fmla , test_data){
  num_models <- object %>% summary() %>% pluck("which") %>% dim() %>% .[1]
  test_mse <- rep(NA, num_models)
  obs_target <- test_data %>% 
    as_tibble() %>% 
    pull(!!as.formula(fmla)[[2]])
  for(i in 1:num_models){
    pred <- predict_regsubset(object, fmla, test_data, model_id = i)
    test_mse[i] <- mean((obs_target - pred)^2)
  }
  tibble(model_index = 1:num_models,
         test_mse    = test_mse)
}

test_mse_regsubset <- function(object, fmla , test_data){
  num_models <- object %>% summary() %>% pluck("which") %>% dim() %>% .[1]
  test_mse <- rep(NA, num_models)
  obs_target <- test_data %>% 
    as_tibble() %>% 
    pull(!!as.formula(fmla)[[2]])
  for(i in 1:num_models){
    pred <- predict_regsubset(object, fmla, test_data, model_id = i)
    test_mse[i] <- mean((obs_target - pred)^2)
  }
  tibble(model_index = 1:num_models,
         test_mse    = test_mse)
}

catchers_bestsubset_cv <- catchers_mod_bldg_dat %>% 
  crossv_kfold(10, id = "folds") %>% 
  mutate(
    fmla = "fraa_adj ~ .",
    model_fits = map2(fmla, train, 
                      ~ regsubsets(as.formula(.x), data = .y, nvmax = 16)),
    model_fold_mse = pmap(list(model_fits, fmla ,test), test_mse_regsubset)
  )

catchers_bestsubset_cv %>% 
  unnest(model_fold_mse) %>% 
  group_by(model_index) %>%  
  summarise(test_mse = mean(test_mse)) %>% 
  arrange(test_mse)

# The best subset selection model included three variables which definitely includes Fielding Runs Above Average with a test MSE lower than the linear model and higher than lasso/ridge models.

# Principal Components Regression and Partial Least Squares -----------------------------------------

pcr_cv_catchers <- catchers_mod_bldg_dat %>% 
  pcr(fraa_adj ~ ., data = ., scale = TRUE, validation = "CV")

# Root Mean Squared Error
validationplot(pcr_cv_catchers)
# Add vertical line at 13
abline(v = 13) 

# Mean Squared Error
validationplot(pcr_cv_catchers, val.type="MSEP")
abline(v = 7) 

pcr_cv_catchers %>% 
  summary()

pls_cv_catchers <- catchers_mod_bldg_dat %>% 
  plsr(fraa_adj ~ ., data = ., scale = TRUE,
       validation = "CV")

validationplot(pls_cv_catchers)
abline(v = 7)

validationplot(pls_cv_catchers, val.type = "MSEP")
abline(v = 5)

catchers_dim_reduct <- catchers_split %>% 
  mutate(
    pcr_13m = map(catchers_mod_comp_dat, ~ pcr(fraa_adj ~ ., data = .x,
                                               ncomp = 13)),
    pcr_7m = map(catchers_mod_comp_dat, ~ pcr(fraa_adj ~ ., data = .x,
                                               ncomp = 7)),
    pls_5m = map(catchers_mod_comp_dat, ~ pcr(fraa_adj ~ ., data = .x,
                                              ncomp = 5))
  ) %>% 
  pivot_longer(cols = c(-catchers_mod_bldg_dat, -catchers_mod_comp_dat), names_to = "method",
               values_to = "fit")

catchers_dim_error <- catchers_dim_reduct %>% 
  mutate(pred = pmap(list(fit, catchers_mod_bldg_dat, c(13, 7, 5)), predict),
         test_mse = map2_dbl(catchers_mod_bldg_dat, pred, ~ mean((.x$fraa_adj - .y)^2))) %>% 
  unnest(test_mse) %>% 
  select(method, test_mse) %>% 
  arrange(test_mse) %>%
  knitr::kable(digits = 3)

catchers_dim_error

# The PCR model with 13 components seemed to perform the best out of the two types of models in this section.
# It had a test MSE similar to the previous models in the report and same as the linear regression model.
# The PLS model with 5 components did not perform well compared to the rest at about a test MSE of about 11.

# Conclusion --------------------------------------------------------------

# The candidate models were chosen from those models we used throughout the course with the Boston dataset.
# This final dataset for my project ended up being very similar in number of observations and number of variables so it seemed appropriate and beneficial to use similar methods.
# There were no variables that rendered a binary response and that is why I did not choose to use models that worked well with classification.
# The linear regression model using all the variables served as a reference for the other candidate models to compare with since it is a reliable and simple model.

# The final model was selected when accounting for the lowest test mean squared error and the highest proportion of the variance in CDA explained.
# The lasso_min model performed the best out of the models chosen resulting in a test mean squared error of 3.16 and a proportion of 93.7% of the variance in CDA explained.
# The model also retained Runs From Extra Strikes which could possibly prove that this metric from Statcast can replace the metric from Baseball Prospectus for a more accurate version when predicting catcher's overall defense.
# In addition, it also kept Strike Rate, Blocking Runs, and Strike Zones 14 and 16.
# Framing is an integral part of evaluating the quality of a catcher's defense and to have a better understanding when comparing catchers.
# Statcast providing state-of-art technology is a plus that allows baseball analysts to further their studies when it comes to defense, a difficult avenue to quanitfy in the game of baseball.
# What we can do to improve these metrics is to keep adding data for this season (hopefully there is a season) and the ones to come as Statcast is simultaneously improving as well as the statistics I covered in this project.
# Other entities such as FanGraphs and Baseball have new, specific metrics for catchers that could be potential variables for the dataset.
# Lastly, another model I could have used was Polynomial Regression and could have used Cross-Validation and Validation




