####################
####################
### Function: take_the_best
### Inputs:   nCV,ipp,bp,Bi,cp,Ci,budget
### Author:   Ian Durbach (indurbach@gmail.com)
### Update:   25/2/2016
###
### Generates a portfolio using a "take-the-best"-like heuristic. Adds
### alternatives one at a time, in order of the bp/cp (benefit-to-cost)-ratios.
### If the addition of an alternative would lead to the budget being exceeded, 
### it is excluded and the next alternative is tried. Terminates after nCV 
### consecutive budget violations (set to nCV > number of alternatives to turn
### this stopping condition off).
####################
####################

take_the_best = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  n = length(bp)
  
  
  
  # generate TTB portfolio
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  
  # start with empty portfolio
  my_z = rep(0,n)

  # order alternatives by cost/benefit ratio
  cb_ratio = cp/bp
  cb_ratio[my_z == 1] = 100000000 #alternatives already in portfolio come last!
  alts = sort.int(cb_ratio,index.return = T)$ix
  
  
  while((cv < nCV)&(i < n)){
  
    # proposed addition to portfolio
    new_alt = alts[i]
    
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
    }
    
    # move on to next alternative
    i = i + 1
    
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                          cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}

greedy_value = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  n = length(bp)
  
  # order alternatives by benefit ratio
  cb_ratio = bp
  alts = sort.int(cb_ratio,index.return = T)$ix
  
  # generate TTB portfolio
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  
  # start with empty portfolio
  my_z = rep(0,n)
  
  while((cv < nCV)&(i < n)){
    
    # proposed addition to portfolio
    new_alt = alts[i]
    
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
    }
    
    # move on to next alternative
    i = i + 1
    
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}

greedy_cost = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  n = length(bp)
  
  # order alternatives by cost
  cb_ratio = cp
  alts = sort.int(cb_ratio,index.return = T)$ix
  
  # generate TTB portfolio
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  
  # start with empty portfolio
  my_z = rep(0,n)
  
  while((cv < nCV)&(i < n)){
    
    # proposed addition to portfolio
    new_alt = alts[i]
    
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
    }
    
    # move on to next alternative
    i = i + 1
    
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}



greedy_netvalue = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  getNetValue = function(bp, Bi, my_z, ipp){
    v = bp;
    ptc = project_to_complete(ipp, my_z)
    extra_value = rep(0,length(my_z))
    for (i in 1:length(ptc)){
      extra_value[ptc[i]] = extra_value[ptc[i]] + Bi[i]
    }
    v = bp + extra_value
    return(v)
  }
  
  n = length(bp)
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  # start with empty portfolio
  my_z = rep(0,n)
  
  nothingChanged = 0
  while((cv < nCV)&(i < n)){

    if(nothingChanged == 0){
        net_value = getNetValue(bp, Bi, my_z, ipp)
        # order alternatives by cost/net_benefit ratio
        cb_ratio = cp/net_value
        cb_ratio[my_z == 1] = 100000000 #alternatives already in portfolio come last!
        alts = sort.int(cb_ratio,index.return = T)$ix
        i = 1
    }
    
    # proposed addition to portfolio
    new_alt = alts[i]
    if(my_z[new_alt] == 1)#if the proposed addition is already in the portfolio we made it to the end of the alternatives.
      break;
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
      nothingChanged = 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
      nothingChanged = 1
      # move on to next alternative
      i = i + 1
    }
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
}

#Find the most valuable project in the portfolio and then add the project that has the biggest positive interaction with it.
mvp_max = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  getMVP = function(bp, cp,  Bi, my_z, ipp){
    if(sum(my_z) == 0) return (-1);
    subBi = Bi
    subBi[incompleteInteractions(ipp, my_z)] = 0
    net_values = c()
    for(i in 1:length(bp)){
      net_values = c(net_values, bp[i] + sum(subBi[interactionIncludes(i, ipp)]))
    }
    cb_ratio = (cp/net_values) * my_z
    cb_ratio[my_z == 0] = 100000000 #alternatives not in portfolio come last!
    alts = sort.int(cb_ratio,index.return = T)$ix
    return (alts[1]) #MVP is the first project in the list!
  }
  
  
  getProjectsWithHighestIncompleteInteraction = function(projectindex, Bi, my_z, ipp){
    if(all(Bi == 0)) return (c());
    if(projectindex == -1){
      highestValueInteractions = which(Bi==max(Bi)) #interactions with highest value
    }else{
      interactionsWithProject = interactionIncludes(projectindex, ipp)
      incompleteInteractions = incompleteInteractions(ipp, my_z)
      subBi = Bi[intersect(interactionsWithProject, incompleteInteractions)]
      if(length(subBi) == 0){#There are no incomplete interactions with project
        highestValueInteractions = which(Bi==max(Bi))
      }else{
        highestValueInteractions = which(Bi == max(subBi)) #interactions with highest value
        highestValueInteractions[highestValueInteractions %in% interactionIncludes(projectindex, ipp)]
      }
    }

    idx = 1
    projects <- c()
    for (i in 1:length(ipp)){
      for(j in 1:ncol(ipp[[i]])){
        if(idx %in% highestValueInteractions){
            projects <- c(projects, unlist(ipp[[i]][,j]));
        }
        idx = idx + 1
      }
    }
    return (sample(setdiff(projects, which(my_z == 1))))
  }
  
  n = length(bp)
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  # start with empty portfolio
  my_z = rep(0,n)
  
  nothingChanged = 0
  while((cv < nCV)&(i < n)){
    
    if(nothingChanged == 0){
      mvp = getMVP(bp, cp, Bi, my_z, ipp)
      net_value = getNetValueSingleProject(bp, Bi, my_z, ipp, mvp)
      # order alternatives by cost/net_benefit ratio
      cb_ratio = cp/net_value
      cb_ratio[my_z == 1] = 100000000 #alternatives already in portfolio come last!
      alts = sort.int(cb_ratio,index.return = T)$ix
      i = 1
    }
    
    # proposed addition to portfolio
    new_alt = alts[i]
    
    if(my_z[new_alt] == 1)#if the proposed addition is already in the portfolio we made it to the end of the alternatives.
      break;
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
      nothingChanged = 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
      nothingChanged = 1
      # move on to next alternative
      i = i + 1
    }
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}

#Find the least valuable project in the portfolio and then add the project that has the biggest positive interaction with it.
lvp_max = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  getLVP = function(bp, cp,  Bi, my_z, ipp){
    if(sum(my_z) == 0) return (-1);
    subBi = Bi
    subBi[incompleteInteractions(ipp, my_z)] = 0
    net_values = c()
    for(i in 1:length(bp)){
      net_values = c(net_values, bp[i] + sum(subBi[interactionIncludes(i, ipp)]))
    }
    cb_ratio = (cp/net_values) * my_z
    cb_ratio[my_z == 0] = -1000000 #alternatives not in portfolio come first!
    alts = sort.int(cb_ratio,index.return = T)$ix
    return (alts[length(alts)]) #LVP is the first project in the list!
  }
  
  getProjectsWithHighestIncompleteInteraction = function(projectindex, Bi, my_z, ipp){
    if(all(Bi == 0)) return (c());
    if(projectindex == -1){
      highestValueInteractions = which(Bi==max(Bi)) #interactions with highest value
    }else{
      interactionsWithProject = interactionIncludes(projectindex, ipp)
      incompleteInteractions = incompleteInteractions(ipp, my_z)
      subBi = Bi[intersect(interactionsWithProject, incompleteInteractions)]
      if(length(subBi) == 0){#There are no incomplete interactions with project
        highestValueInteractions = which(Bi==max(Bi))
      }else{
        highestValueInteractions = which(Bi == max(subBi)) #interactions with highest value
        highestValueInteractions[highestValueInteractions %in% interactionIncludes(projectindex, ipp)]
      }
    }
    idx = 1
    projects <- c()
    for (i in 1:length(ipp)){
      for(j in 1:ncol(ipp[[i]])){
        if(idx %in% highestValueInteractions){
          projects <- c(projects, unlist(ipp[[i]][,j]));
        }
        idx = idx + 1
      }
    }
    return (sample(setdiff(projects, which(my_z == 1))))
  }
  
  n = length(bp)
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  # start with empty portfolio
  my_z = rep(0,n)
  
  nothingChanged = 0
  while((cv < nCV)&(i < n)){
    
    if(nothingChanged == 0){
      lvp = getLVP(bp, cp, Bi, my_z, ipp)
      net_value = getNetValueSingleProject(bp, Bi, my_z, ipp, lvp)
      # order alternatives by cost/net_benefit ratio
      cb_ratio = cp/net_value
      cb_ratio[my_z == 1] = 100000000 #alternatives already in portfolio come last!
      alts = sort.int(cb_ratio,index.return = T)$ix
      i = 1
    }
    
    
    # proposed addition to portfolio
    new_alt = alts[i]
    
    if(my_z[new_alt] == 1)#if the proposed addition is already in the portfolio we made it to the end of the alternatives.
      break;
    # proposed portfolio
    my_z[new_alt] = 1
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
      nothingChanged = 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
      nothingChanged = 1
      # move on to next alternative
      i = i + 1
    }
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}

#Find a random project in the portfolio and then add the project that has the biggest positive interaction with it.
rvp_max = function(nCV,ipp,bp,Bi,cp,Ci,budget){
  
  getProjectsWithHighestIncompleteInteraction = function(projectindex, Bi, my_z, ipp){
    if(all(Bi == 0)) return (c());
    if(projectindex == -1){
      highestValueInteractions = which(Bi==max(Bi)) #interactions with highest value
    }else{
      interactionsWithProject = interactionIncludes(projectindex, ipp)
      incompleteInteractions = incompleteInteractions(ipp, my_z)
      subBi = Bi[intersect(interactionsWithProject, incompleteInteractions)]
      if(length(subBi) == 0){#There are no incomplete interactions with project
        highestValueInteractions = which(Bi==max(Bi))
      }else{
        highestValueInteractions = which(Bi == max(subBi)) #interactions with highest value
        highestValueInteractions[highestValueInteractions %in% interactionIncludes(projectindex, ipp)]
      }
    }
    idx = 1
    projects <- c()
    for (i in 1:length(ipp)){
      for(j in 1:ncol(ipp[[i]])){
        if(idx %in% highestValueInteractions){
          projects <- c(projects, unlist(ipp[[i]][,j]));
        }
        idx = idx + 1
      }
    }
    return (sample(setdiff(projects, which(my_z == 1))))
  }
  
  n = length(bp)
  i = 1
  cv = 0 # index for consecutive constraint violations (terminate when = 3)
  # start with empty portfolio
  my_z = rep(0,n)
  
  nothingChanged = 0
  while((cv < nCV)&(i < n)){
    if(nothingChanged == 0){
      if(length(which(my_z == 1)) > 0){
        rvp = sample(which(my_z == 1), 1) 
      }else{
        rvp = -1
      }
      net_value = getNetValueSingleProject(bp, Bi, my_z, ipp, rvp)
      # order alternatives by cost/net_benefit ratio
      cb_ratio = cp/net_value
      cb_ratio[my_z == 1] = 100000000 #alternatives already in portfolio come last!
      alts = sort.int(cb_ratio,index.return = T)$ix
      i = 1
    }
    
    # proposed addition to portfolio
    new_alt = alts[i]
    
    if(my_z[new_alt] == 1)#if the proposed addition is already in the portfolio we made it to the end of the alternatives.
      break;
    # proposed portfolio
    my_z[new_alt] = 1
    
    # evaluate proposed portfolio
    my_propsol = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                            cp = cp, Ci = Ci, budget = budget)  
    
    # if feasible, accept; if not feasible, reject
    if(my_propsol$feasible == 1){
      my_z[new_alt] = 1 # accept proposed alternative in portfolio
      cv = 0   # reset constraint violation counter to 0
      nothingChanged = 0
    }else{
      my_z[new_alt] = 0  # reject proposed alternative in portfolio
      cv = cv + 1    # increment constrain violation counter
      nothingChanged = 1
      # move on to next alternative
      i = i + 1
    }
  }
  
  final_z = my_z
  
  final_res = evaluate_z(z = my_z, ipp = ipp, bp  = bp, Bi = Bi, 
                         cp = cp, Ci = Ci, budget = budget) 
  
  benefit = final_res$benefit 
  cost = final_res$cost 
  feasible = final_res$feasible
  g = final_res$g 
  
  
  return(list(final_z=final_z,benefit=benefit,cost=cost,feasible=feasible,g=g))
  
}

#returns an array with the index of the project left to complete each interaction.
#if the interaction is complete or more than one project is needed then the index is 0.
project_to_complete = function(ipp_local, my_z, Bi){
  projects_included = which(my_z==1)
  rslt = c()
  idx = 1;
  for (i in 1:length(ipp_local)){
    for (j in 1:ncol(ipp_local[[i]])){
      projects_missing_interaction = ipp_local[[i]][,j][which(!(ipp_local[[i]][,j] %in% projects_included))]
      if(length(projects_missing_interaction) == 1)
        rslt[idx] = projects_missing_interaction[1]
      else
        rslt[idx] = 0
      
      idx = idx+1
    }
  }
  return(rslt)
}


#returns the indices of the interactions that include project projectindex
interactionIncludes = function(projectindex, ipp){
  idx = 1
  indices <- c()
  for (i in 1:length(ipp)){
    for (j in 1:ncol(ipp[[i]])){
      if(projectindex %in% ipp[[i]][,j]){
        indices <- c(indices, idx)
      }
      idx = idx+1
    }
  }
  return(indices)
}

#returns an array with the indices of the interactions that have been completed in the portfolio.
completedInteractions = function(ipp, my_z){
  projects_included = which(my_z==1)
  rslt = c()
  idx = 1;
  for (i in 1:length(ipp)){
    for (j in 1:ncol(ipp[[i]])){
      projects_missing_interaction = ipp[[i]][,j][which(!(ipp[[i]][,j] %in% projects_included))]
      if(length(projects_missing_interaction) == 0){
        rslt = c(rslt, idx)
      }
      idx = idx+1
    }
  }
  return(rslt)
}

#returns an array with the indices of the interactions that have not been completed in the portfolio.
incompleteInteractions = function(ipp, my_z){
  projects_included = which(my_z==1)
  rslt = c()
  idx = 1;
  for (i in 1:length(ipp)){
    for (j in 1:ncol(ipp[[i]])){
      projects_missing_interaction = ipp[[i]][,j][which(!(ipp[[i]][,j] %in% projects_included))]
      if(length(projects_missing_interaction) != 0){
        rslt = c(rslt, idx)
      }
      idx = idx+1
    }
  }
  return(rslt)
}

#returns an array with the extra value added by each project from the interaction with a chosen project.
getNetValueSingleProject = function(bp, Bi, my_z, ipp, pid){
  v = bp;
  interactionsSingleProject = interactionIncludes(pid, ipp)
  ippbi = reduceInteractionsTo(ipp, Bi, interactionsSingleProject)
  ipp_red = ippbi$newipp
  Bi_red = ippbi$newbi
  if(length(ipp_red) == 0) return(bp)
  ptc = project_to_complete(ipp_red, my_z)
  extra_value = rep(0,length(my_z))
  for (i in 1:length(ptc)){
      extra_value[ptc[i]] = extra_value[ptc[i]] + Bi_red[i]
  }
  v = bp + extra_value
  return(v)
}

reduceInteractionsTo = function(ipp, Bi, interactionsSingleProject){
  newipp = list()
  newbi = c()
  idx = 1;
  for (i in 1:length(ipp)){
    for (j in 1:ncol(ipp[[i]])){
      if(idx %in% interactionsSingleProject)
        newipp[[length(newipp)+1]] <- matrix(ipp[[i]][,j])
        newbi = c(newbi, Bi[idx])
        idx = idx+1
    }
  }
  return(list(newipp = newipp, newbi =  newbi))
}