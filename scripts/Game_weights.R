# State hunting quotas 

#Read data
state_quotas <- read.csv('data/HKC_ZW_State_huntingQuotas_2000-2019.csv',sep=',')
lifehist <- read.csv('data/HKC_LifeHistory_v6.csv',sep=',')

weights <- lifehist[,c(8,28)]
#weights$female_body_mass_g <- ifelse(weights$female_body_mass_g<0,weights$male_body_mass_g,weights$female_body_mass_g)
#weights$male_body_mass_g <- ifelse(weights$male_body_mass_g<0,weights$female_body_mass_g,weights$male_body_mass_g)
species <- as.data.frame(unique(state_quotas$Species))
names(species) <- c("common_name")
game_weights <- read.csv('data/game_weights.csv',sep=',')


meat <- merge(state_quotas,game_weights,by.x='Species',by.y='common_name')

### Game weights edited to include blanks in weight

meat$quota_weight <- meat$Quota*meat$Adult.Body.Mass.Kg

# Writing will overwite the data that was manually entered .
# write.csv(meat,'data/hkc_zw_state_quotas_clean.csv')
