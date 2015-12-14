window.TMPL={},TMPL.airlock_electronics=function(e,s,a){var n='<article class="display"><section>';n+=e.oneAccess?""+a.link("One Required","unlock","one_access"):""+a.link("All Required","lock","one_access"),n+=""+a.link("Clear","refresh","clear")+'<section><table class="grow"><thead><tr>';var l=e.regions;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+='<th><span class="highlight bold">'+t.name+"</span></th>";n+="</tr></thead><tbody><tr>";var o=e.regions;if(o)for(var t,c=-1,r=o.length-1;r>c;){t=o[c+=1],n+="<td>";var d=t.accesses;if(d)for(var p,u=-1,v=d.length-1;v>u;)p=d[u+=1],n+=""+a.link(p.name,p.req?"check-square-o":"square-o","set",{access:p.id},null,p.req?"selected":null)+"<br />";n+="</td>"}return n+="</tr></tbody></table></article>"},TMPL.air_alarm=function(e,s,a){var n='<article class="notice">';if(n+=e.siliconUser?'<section><span class="label">Interface Lock:</span><div class="content">'+a.link("Engaged","lock","toggleaccess",null,e.locked?"selected":null)+a.link("Disengaged","unlock","toggleaccess",null,e.locked?null:"selected")+"</div></section>":e.locked?"<span>Swipe an ID card to unlock this interface.</span>":"<span>Swipe an ID card to lock this interface.</span>",n+='</article><article class="display"><header><h2>Air Status</h2></header>',e.environment_data){var l=e.environment_data;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+='<section><span class="label">'+t.name+':</span><div class="content">',n+=2==t.danger_level?'<span class="bad">':1==t.danger_level?'<span class="average">':'<span class="good">',n+=""+a.fixed(t.value,2)+t.unit+"</span></div></section>";n+='<section><span class="label">Local Status:</span><div class="content">',n+=2==e.danger_level?'<span class="bad bold">Danger (Internals Required)</span>':1==e.danger_level?'<span class="average bold">Caution</span>':'<span class="good">Optimal</span>',n+='</div></section><section><span class="label">Area Status:</span><div class="content">',n+=e.atmos_alarm?'<span class="bad bold">Atmosphere Alarm</span>':e.fire_alarm?'<span class="bad bold">Fire Alarm</span>':'<span class="good">Nominal</span>',n+="</div></section>"}else n+='<section><span class="bad bold">Warning: Cannot obtain air sample for analysis.</span></section>';if(e.dangerous&&(n+='<hr /><section><span class="bad bold">Warning: Safety measures offline. Device may exhibit abnormal behavior.</span></section>'),n+="</article>",!e.locked||e.siliconUser)if(1!=e.screen&&(n+=""+a.link("Back","arrow-left","screen",{screen:1})),1==e.screen)n+='<article class="display"><header><h2>Air Controls</h2></header><section class="button">',n+=e.atmos_alarm?""+a.link("Area Atmospheric Alarm","close","reset",null,null,"caution"):""+a.link("Area Atmospheric Alarm","hand-stop-o","alarm"),n+='</section><section class="button">',n+=3!=e.mode?""+a.link("Panic Siphon","exclamation","mode",{mode:3}):""+a.link("Panic Siphon","close","mode",{mode:1},null,"danger"),n+='</section><section class="button">'+a.link("Vent Controls","sign-out","screen",{screen:2})+'</section><section class="button">'+a.link("Scrubber Controls","filter","screen",{screen:3})+'</section><section class="button">'+a.link("Set Environmental Mode","cog","screen",{screen:4})+'</section><section class="button">'+a.link("Set Alarm Threshold","bar-chart","screen",{screen:5})+"</section></article>";else if(2==e.screen){var o=e.vents;if(o)for(var r,c=-1,d=o.length-1;d>c;)r=o[c+=1],n+='<article class="display"><header><h3>'+r.long_name+'</h3></header><section><span class="label">Power:</span><div class="content">',n+=r.power?""+a.link("On","power-off","adjust",{id_tag:r.id_tag,command:"power",val:0},null,null):""+a.link("Off","close","adjust",{id_tag:r.id_tag,command:"power",val:1},null,"danger"),n+='</div></section><section><span class="label">Mode:</span><div class="content">',n+="release"==r.direction?'<span class="good">Pressurizing</span>':'<span class="bad">Siphoning</span>',n+='</div></section><section><span class="label">Pressure Checks:</span><div class="content">'+a.link("Internal","sign-in","adjust",{id_tag:r.id_tag,command:"incheck",val:r.checks},null,r.incheck?"selected":null)+a.link("External","sign-out","adjust",{id_tag:r.id_tag,command:"excheck",val:r.checks},null,r.excheck?"selected":null)+'</div></section><section><span class="label">Set Pressure:</span><div class="content">'+a.link(a.fixed(r.external),"pencil","adjust",{id_tag:r.id_tag,command:"set_external_pressure"})+a.link("Reset","refresh","adjust",{id_tag:r.id_tag,command:"reset_external_pressure"},r.extdefault?"disabled":null)+"</div></section></article>";e.vents.length||(n+='<span class="bad">No vents connected.</span>')}else if(3==e.screen){var p=e.scrubbers;if(p)for(var u,c=-1,v=p.length-1;v>c;)u=p[c+=1],n+='<article class="display"><header><h3>'+u.long_name+'</h3></header><section><span class="label">Power:</span><div class="content">',n+=u.power?""+a.link("On","power-off","adjust",{id_tag:u.id_tag,command:"power",val:0},null,null):""+a.link("Off","close","adjust",{id_tag:u.id_tag,command:"power",val:1},null,"danger"),n+='</div></section><section><span class="label">Mode:</span><div class="content">',n+=u.scrubbing?""+a.link("Scrubbing","filter","adjust",{id_tag:u.id_tag,command:"scrubbing",val:0},null,null):""+a.link("Siphoning","sign-in","adjust",{id_tag:u.id_tag,command:"scrubbing",val:1},null,"danger"),n+='</div></section><section><span class="label">Range:</span><div class="content">',n+=u.widenet?""+a.link("Extended","expand","adjust",{id_tag:u.id_tag,command:"widenet",val:0},null,"caution"):""+a.link("Normal","compress","adjust",{id_tag:u.id_tag,command:"widenet",val:1},null,null),n+='</div></section><section><span class="label">Filters:</span><div class="content">'+a.link("CO2",u.filter_co2?"check-square-o":"square-o","adjust",{id_tag:u.id_tag,command:"co2_scrub",val:u.filter_co2?0:1},null,u.filter_co2?"selected":null)+a.link("N2O",u.filter_n2o?"check-square-o":"square-o","adjust",{id_tag:u.id_tag,command:"n2o_scrub",val:u.filter_n2o?0:1},null,u.filter_n2o?"selected":null)+a.link("Plasma",u.filter_toxins?"check-square-o":"square-o","adjust",{id_tag:u.id_tag,command:"tox_scrub",val:u.filter_toxins?0:1},null,u.filter_toxins?"selected":null)+"</div></section></article>";e.scrubbers.length||(n+='<span class="bad">No scrubbers connected.</span>')}else if(4==e.screen){n+='<article class="display"><header><h2>Environmental Modes</h2></header>';var h=e.modes;if(h)for(var b,c=-1,k=h.length-1;k>c;)b=h[c+=1],n+='<section class="button">'+a.link(b.name,b.selected?"check-square-o":"square-o","mode",{mode:b.mode},null,b.selected?b.danger?"danger":"selected":null)+"</section>";n+="</display>"}else if(5==e.screen){n+='<article class="display"><header><h2>Alarm Thresholds</h2></header><table><thead><tr><th></th><th><span class="bad">min2</span></th><th><span class="average">min1</span></th><th><span class="average">max1</span></th><th><span class="bad">max2</span></th></tr></thead><tbody>';var g=e.thresholds;if(g)for(var f,c=-1,m=g.length-1;m>c;){f=g[c+=1],n+="<tr><th>"+f.name+"</th>";var w=f.settings;if(w)for(var _,P=-1,y=w.length-1;y>P;)_=w[P+=1],n+="<td>"+a.link(_.selected>=0?a.round(100*_.selected)/100:"Off",null,"adjust",{command:"set_threshold",env:_.env,"var":_.val})+"</td>";n+="</tr>"}n+="</tbody><table></article>"}return n},TMPL.apc=function(e,s,a){var n='<article class="notice">';n+=e.siliconUser?'<section><span class="label">Interface Lock:</span><div class="content">'+a.link("Engaged","lock","toggleaccess",null,e.locked?"selected":null)+a.link("Disengaged","unlock","toggleaccess",null,e.malfStatus>=2?"linkOff":e.locked?null:"selected")+"</div></section>":e.locked?"<span>Swipe an ID card to unlock this interface.</span>":"<span>Swipe an ID card to lock this interface.</span>",n+='</article><article class="display"><header><h2>Power Status</h2></header><section><span class="label">Main Breaker:</span><div class="content">',n+=e.locked&&!e.siliconUser?e.isOperating?'<span class="good">On</span>':'<span class="bad">Off</span>':""+a.link("On","power-off","breaker",null,e.isOperating?"selected":null)+a.link("Off","close","breaker",null,e.isOperating?null:"selected"),n+='</div></section><section><span class="label">External Power:</span><div class="content">',n+=2==e.externalPower?'<span class="good">Good</span>':1==e.externalPower?'<span class="average">Low</span>':'<span class="bad">None</span>',n+='</div></section><section><span class="label">Power Cell:</span><div class="content">',n+=null!=e.powerCellStatus?""+a.bar(e.powerCellStatus,0,100,e.powerCellStatus>=50?"good":e.powerCellStatus>=25?"average":"bad",a.fixed(e.powerCellStatus)+"%"):'<span class="bad">Power cell removed.</span>',n+="</div></section>",null!=e.powerCellStatus&&(n+='<section><span class="label">Charge Mode:</span><div class="content">',n+=e.locked&&!e.siliconUser?e.chargeMode?'<span class="good">Auto</span>':'<span class="bad">Off</span>':""+a.link("Auto","refresh","chargemode",null,e.chargeMode?"selected":null)+a.link("Off","close","chargemode",null,e.chargeMode?null:"selected"),n+="&nbsp;",n+=e.chargingStatus>1?'[<span class="good">Fully Charged</span>]':1==e.chargingStatus?'[<span class="average">Charging</span>]':'[<span class="bad">Not Charging</span>]',n+="</div></section>"),n+='</article><article class="display"><header><h2>Power Channels</h2></header><table class="grow">';var l=e.powerChannels;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+="<tr><th>"+t.title+":</th><td>"+t.powerLoad+" W</td><td>",t.status<=1?n+='<span class="bad">Off</span>':t.status>=2&&(n+='<span class="good">On</span>'),n+="</td><td>",n+=1==t.status||3==t.status?"[Auto]":"[Manual]",n+='</td><td class="floatRight">',(!e.locked||e.siliconUser)&&(n+=""+a.link("Auto","refresh","channel",t.topicParams.auto,1==t.status||3==t.status?"selected":null)+a.link("On","power-off","channel",t.topicParams.on,2==t.status?"selected":null)+a.link("Off","close","channel",t.topicParams.off,0==t.status?"selected":null)),n+="</td></tr>";return n+='<tr><th>Total Load:</th><td class="bold">'+e.totalLoad+" W</td><td></td><td></td><td></td></tr></table></article>",e.siliconUser&&(n+='<article class="display"><header><h2>System Overrides</h2></header><section>'+a.link("Overload Lighting Circuit","lightbulb-o","overload")+"</section><section>",1==e.malfStatus?n+=""+a.link("Override Programming","terminal","hack"):2==e.malfStatus?n+=""+a.link("Shunt Core Processes","caret-square-o-down","occupy"):3==e.malfStatus?n+=""+a.link("Return to Main Core","carat-square-o-left","deoccupy"):4==e.malfStatus&&(n+=""+a.link("Shunt Core Processes","caret-square-o-down")),n+="</section></article>"),n+='<article class="notice"><section><span class="label">Cover Lock:</span><div class="content">',n+=e.locked&&!e.siliconUser?e.coverLocked?"<span>Engaged</span>":"<span>Disengaged</span>":""+a.link("Engaged","lock","lock",null,e.coverLocked?"selected":null)+a.link("Disengaged","unlock","lock",null,e.coverLocked?null:"selected"),n+="</div></section></article>"},TMPL.atmos_filter=function(e,s,a){var n='<article class="display"><section><span class="label">Power:</span><div class="content">'+a.link(e.on?"On":"Off",e.on?"power-off":"close","power")+'</div></section><section><span class="label">Output Pressure:</span><div class="content">'+a.link("Set","pencil","pressure",{set:"custom"})+a.link("Max","plus","pressure",{set:"max"},e.set_pressure==e.max_pressure?"disabled":null)+'<span class="buttoninfo">'+e.set_pressure+' kPa</span></div></section><section><span class="label">Filter:</span><div class="content">'+a.link("Nothing",null,"filter",{mode:-1},-1==e.filter_type?"selected":null)+a.link("Plasma",null,"filter",{mode:0},0==e.filter_type?"selected":null)+a.link("O2",null,"filter",{mode:1},1==e.filter_type?"selected":null)+a.link("N2",null,"filter",{mode:2},2==e.filter_type?"selected":null)+a.link("CO2",null,"filter",{mode:3},3==e.filter_type?"selected":null)+a.link("N2O",null,"filter",{mode:4},4==e.filter_type?"selected":null)+"</div></section></article>";return n},TMPL.atmos_mixer=function(e,s,a){var n='<article class="display"><section><span class="label">Power:</span><div class="content">'+a.link(e.on?"On":"Off",e.on?"power-off":"close","power")+'</div></section><section><span class="label">Output Pressure:</span><div class="content">'+a.link("Set","pencil","pressure",{set:"custom"})+a.link("Max","plus","pressure",{set:"max"},e.set_pressure==e.max_pressure?"disabled":null)+'<span class="buttoninfo">'+e.set_pressure+' kPa</span></div></section><section><span class="label">Node 1:</span><div class="content">'+a.link("","fast-backward","node1",{concentration:"-0.1"},null)+a.link("","backward","node1",{concentration:"-0.01"},null)+a.link("","forward","node1",{concentration:"0.01"},null)+a.link("","fast-forward","node1",{concentration:"0.1"},null)+'<span class="buttoninfo">'+e.node1_concentration+'%</span></div></section><section><span class="label">Node 2:</span><div class="content">'+a.link("","fast-backward","node2",{concentration:"-0.1"},null)+a.link("","backward","node2",{concentration:"-0.01"},null)+a.link("","forward","node2",{concentration:"0.01"},null)+a.link("","fast-forward","node2",{concentration:"0.1"},null)+'<span class="buttoninfo">'+e.node2_concentration+"%</span></div></section></article>";return n},TMPL.atmos_pump=function(e,s,a){var n='<article class="display"><section><span class="label">Power:</span><div class="content">'+a.link(e.on?"On":"Off",e.on?"power-off":"close","power")+"</div></section>";return n+=e.max_rate?'<section><span class="label">Transfer Rate:</span><div class="content">'+a.link("Set","pencil","transfer",{set:"custom"})+a.link("Max","plus","transfer",{set:"max"},e.transfer_rate==e.max_rate?"disabled":null)+'<span class="buttoninfo">'+e.transfer_rate+" L/s</span></div></section>":'<section><span class="label">Output Pressure:</span><div class="content">'+a.link("Set","pencil","pressure",{set:"custom"})+a.link("Max","plus","pressure",{set:"max"},e.set_pressure==e.max_pressure?"disabled":null)+'<span class="buttoninfo">'+e.set_pressure+" kPa</span></div></section>",n+="</article>"},TMPL.canister=function(e,s,a){var n='<article class="notice">';return n+=e.hasHoldingTank?"<span>The regulator is connected to a tank.</span>":"<span>The regulator is not connected to a tank.</span>",n+='</article><article class="display"><header><h2>Canister</h2></header><section>'+a.link("Relabel","pencil","relabel",null,e.canLabel?null:"disabled")+'</section><section><span class="label">Pressure:</span><div class="content"><span>'+e.tankPressure+' kPa</span></div></section><section><span class="label">Port:</span><div class="content">',n+=e.portConnected?'<span class="good">Connected</span>':'<span class="bad">Disconnected</span>',n+='</div></section></article><article class="display"><header><h2>Valve</h2></header><section><span class="label">Release Pressure:</span><div class="content">'+a.bar(e.releasePressure,e.minReleasePressure,e.maxReleasePressure,null,e.releasePressure+" kPa")+'</div></section><section><div class="label">Pressure Regulator:</div><div class="content">'+a.link("Reset","refresh","pressure",{set:"reset"},e.releasePressure!=e.defaultReleasePressure?null:"disabled")+a.link("Min","minus","pressure",{set:"min"},e.releasePressure>e.minReleasePressure?null:"disabled")+a.link("Set","pencil","pressure",{set:"custom"},null)+a.link("Max","plus","pressure",{set:"max"},e.releasePressure<e.maxReleasePressure?null:"disabled")+'</div></section><section><div class="label">Valve:</div><div class="content">'+a.link("Open","unlock","valve",null,e.valveOpen?"selected":null)+a.link("Close","lock","valve",null,e.valveOpen?null:"selected")+'</div></section></article><article class="display"><header><h2>Holding Tank</h2></header>',n+=e.hasHoldingTank?"<section>"+a.link("Eject","eject","eject")+'</section><section><span class="label">Label:</span><div class="content">'+e.holdingTank.name+'</div></section><section><span class="label">Tank Pressure:</span><div class="content">'+e.holdingTank.tankPressure+" kPa</div></section>":'<section><span class="average">No Holding Tank</span></section>',n+="</article>"},TMPL.chem_dispenser=function(e,s,a){var n='<article class="display"><header><h2>Status</h2></header><section><span class="label">Energy:</span><div class="content">'+a.bar(e.energy,0,e.maxEnergy,null,e.energy+" Units")+'</div></section><section><span class="label">Amount:</span><div class="content">',l=e.beakerTransferAmounts;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+=""+a.link(t,"plus","amount",{set:t},e.amount==t?"selected":null);n+='</div></section></article><article class="display"><header><h2>Dispense</h2></header><section>';var o=e.chemicals;if(o)for(var r,c=-1,d=o.length-1;d>c;)r=o[c+=1],n+=""+a.link(r.title,"tint","dispense",r.commands,null,"gridable");n+='</div></section><article class="display"><header><h2>Beaker</h2></header><section><div class="label">'+a.link("Eject","eject","eject",null,e.isBeakerLoaded?null:"disabled")+'</div><div class="content">';var p=e.beakerTransferAmounts;if(p)for(var t,c=-1,u=p.length-1;u>c;)t=p[c+=1],n+=""+a.link(t,"minus","remove",{amount:t});if(n+='</div></section><section><div class="label">Contents:</div><div class="content">',e.isBeakerLoaded)if(e.beakerContents.length){n+="<span>"+e.beakerCurrentVolume+"/"+e.beakerMaxVolume+" Units</span><br />";var v=e.beakerContents;if(v)for(var h,c=-1,b=v.length-1;b>c;)h=v[c+=1],n+='<span class="highlight">'+h.volume+" units of "+h.name+"</span><br />"}else n+='<span class="bad">Beaker Empty</span>';else n+='<span class="average">No Beaker Loaded</span>';return n+="</div></section></article>"},TMPL.chem_heater=function(e,s,a){var n='<article class="display"><header><h2>Status</h2></header><section><span class="label">Power:</span><div class="content">'+a.link(e.isActive?"On":"Off",e.isActive?"power-off":"close","power",null,e.isBeakerLoaded?null:"disabled")+'</div></section><section><span class="label">Target:</span><div class="content">'+a.link(e.targetTemp+"K","pencil","temperature")+'</div></section></article><article class="display"><header><h2>Beaker</h2></header><section>'+a.link("Eject","eject","eject",null,e.isBeakerLoaded?null:"disabled")+'</section><section><span class="label">Contents:</span><div class="content">';if(e.isBeakerLoaded)if(n+="Temperature: "+e.currentTemp+"K<br />",e.beakerContents.length){var l=e.beakerContents;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+='<span class="highlight">'+t.volume+" units of "+t.name+"</span><br />"}else n+='<span class="bad">Beaker Empty</span>';else n+='<span class="average">No Beaker Loaded</span>';return n+="</div></section></div>"},TMPL.cryo=function(e,s,a){var n='<article class="display"><header><h2>Occupant</h2></header><section><span class="label">Occupant:</span><div class="content">';if(n+=e.hasOccupant?"<span>"+e.occupant.name+"</span>":'<span class="average">No Occupant</span>',n+="</div></section>",e.hasOccupant&&(n+='<section><span class="label">State:</span><div class="content">',n+=0==e.occupant.stat?'<span class="good">Conscious</span>':1==e.occupant.stat?'<span class="average">Unconscious</span>':'<span class="bad">Dead</span>',n+='</div></section><section><span class="label">Temperature:</span><div class="content">'+a.round(e.occupant.bodyTemperature)+" K</div></section>"),e.hasOccupant&&e.occupant.stat<2&&(n+='<section><span class="label">Health:</span><div class="content">'+a.bar(e.occupant.health,e.occupant.minHealth,e.occupant.Maxhealth,e.occupant.health>=0?"good":"average",a.round(e.occupant.health))+'</div></section><section><span class="label">Brute:</span><div class="content">'+a.bar(e.occupant.bruteLoss,0,e.occupant.maxHealth,"bad",a.round(e.occupant.bruteLoss))+'</div></section><section><span class="label">Respiratory:</span><div class="content">'+a.bar(e.occupant.oxyLoss,0,e.occupant.maxHealth,"bad",a.round(e.occupant.oxyLoss))+'</div></section><section><span class="label">Toxin:</span><div class="content">'+a.bar(e.occupant.toxLoss,0,e.occupant.maxHealth,"bad",a.round(e.occupant.toxLoss))+'</div><section><section><span class="label">Burn:</span><div class="content">'+a.bar(e.occupant.fireLoss,0,e.occupant.maxHealth,"bad",a.round(e.occupant.fireLoss))+"</div></section>"),n+='</article><article class="display"><header><h2>Cell</h2></header><section><span class="label">Power:</span><div class="content">',n+=e.isOperating?""+a.link("On","power-off","off"):""+a.link("Off","close","on"),n+='</div></section><section><span class="label">Temperature:</span><div class="content"><span class="'+e.cellTemperatureStatus+'">'+e.cellTemperature+' K</span></div></section><section><span class="label">Door:</span><div class="content">',n+=e.isOpen?""+a.link("Open","unlock","close"):""+a.link("Closed","lock","open"),n+=e.autoEject?""+a.link("Auto","sign-out","autoeject"):""+a.link("Manual","sign-in","autoeject"),n+='</div></section></article><article class="display"><header><h2>Beaker</h2></header><section>'+a.link("Eject","eject","ejectbeaker",null,e.isBeakerLoaded?null:"disabled")+'</section><section><span class="label">Contents:</span><div class="content">',e.isBeakerLoaded)if(e.beakerContents.length){var l=e.beakerContents;if(l)for(var t,c=-1,i=l.length-1;i>c;)t=l[c+=1],n+='<span class="highlight">'+t.volume+" units of "+t.name+"</span><br />"}else n+='<span class="bad">Beaker Empty</span>';else n+='<span class="average">No Beaker Loaded</span>';return n+="</div></section></display>"},TMPL.smes=function(e,s,a){var n='<article class="display"><header><h2>Storage</h2></header><section><span class="label">Stored Energy:</span><div class="content">'+a.bar(e.capacityPercent,0,100,e.capacityPercent>=50?"good":e.capacityPercent>=15?"average":"bad",a.round(e.capacityPercent)+"%")+'</div></section></article><article class="display"><header><h2>Input</h2></header><section><span class="label">Charge Mode:</span><div class="content">'+a.link("Auto","refresh","tryinput",null,e.inputAttempt?"selected":null)+a.link("Off","close","tryinput",null,e.inputAttempt?null:"selected")+"&nbsp;";return n+=e.capacityPercent>=99?"[<span class='good'>Fully Charged</span>]":e.inputting?"[<span class='average'>Charging</span>]":"[<span class='bad'>Not Charging</span>]",n+='</div></section><section><span class="label">Input Setting:</span><div class="content">'+a.bar(e.inputLevel,0,e.inputLevelMax,null,e.inputLevel+" W")+'</div></section><section><span class="label">Adjust Input:</span><div class="content">'+a.link("","fast-backward","input",{set:"min"},e.inputLevel?null:"selected")+a.link("","backward","input",{set:"minus"},e.inputLevel?null:"disabled")+a.link("Set","pencil","input",{set:"custom"},null)+a.link("","forward","input",{set:"plus"},e.inputLevel==e.inputLevelMax?"disabled":null)+a.link("","fast-forward","input",{set:"max"},e.inputLevel==e.inputLevelMax?"selected":null)+'</div></section><section><span class="label">Available:</span><div class="content"><span>'+e.inputAvailable+' W</span></div></section></article><article class="display"><header><h2>Output</h2></header><section><span class="label">Charge Mode:</span><div class="content">'+a.link("On","power-off","tryoutput",null,e.outputAttempt?"selected":null)+a.link("Off","close","tryoutput",null,e.outputAttempt?null:"selected")+"&nbsp;",n+=e.outputting?'[<span class="good">Sending</span>]':e.charge>0?'[<span class="average">Not Sending</span>]':'[<span class="bad">No Charge</span>]',n+='</div></section><section><span class="label">Output Setting:</span><div class="content">'+a.bar(e.outputLevel,0,e.outputLevelMax,null,e.outputLevel+" W")+'</div></section><section><span class="label">Adjust Output:</span><div class="content">'+a.link("","fast-backward","output",{set:"min"},e.outputLevel?null:"selected")+a.link("","backward","output",{set:"minus"},e.outputLevel?null:"disabled")+a.link("Set","pencil","output",{set:"custom"},null)+a.link("","forward","output",{set:"plus"},e.outputLevel==e.outputLevelMax?"disabled":null)+a.link("","fast-forward","output",{set:"max"},e.outputLevel==e.outputLevelMax?"selected":null)+'</div></section><section><span class="label">Outputting:</span><div class="content"><span>'+e.outputUsed+" W</span></div></section></article>"},TMPL.solar_control=function(e,s,a){var n='<article class="display"><header><h2>Status</h2></header><section><span class="label">Generated Power:</span><div class="content"><span>'+e.generated+' W</span></div></section><section><span class="label">Orientation:</span><div class="content"><span>'+e.angle+"&deg; ("+e.direction+')</span></div></section><section><span class="label">Adjust:</span><div class="content">'+a.link("15&deg;","step-backward","control",{cdir:"-15"})+a.link("1&deg;","backward","control",{cdir:"-1"})+a.link("1&deg;","forward","control",{cdir:"1"})+a.link("15&deg;","step-forward","control",{cdir:"15"})+'</div></section></article><article class="display"><header><h2>Tracking</h2></header><section><span class="label">Tracker Mode:</span><div class="content">'+a.link("Off","close","tracking",{mode:"0"},0==e.tracking_state?"selected":"")+a.link("Timed","clock-o","tracking",{mode:"1"},1==e.tracking_state?"selected":"");return n+=e.connected_tracker?""+a.link("Auto","refresh","tracking",{mode:"2"},2==e.tracking_state?"selected":""):""+a.link("Auto","refresh",null,null,"disabled"),n+='</div></section><section><span class="label">Tracking Rate:</span><div class="content"><span>'+e.tracking_rate+" deg/h ("+e.rotating_way+')</span></div></section><section><span class="label">Adjust:</span><div class="content">'+a.link("180&deg;","fast-backward","control",{tdir:"-180"})+a.link("30&deg;","step-backward","control",{tdir:"-30"})+a.link("1&deg;","backward","control",{tdir:"-1"})+a.link("1&deg;","forward","control",{tdir:"1"})+a.link("30&deg;","step-forward","control",{tdir:"30"})+a.link("180&deg;","fast-forward","control",{tdir:"180"})+'</div></section></article><article class="display"><header><h2>Devices</h2></header><section><span class="label">Search:</span><div class="content">'+a.link("Refresh","refresh","refresh")+'</div></section><section><span class="label">Solar Tracker:</span><div class="content">',n+=e.connected_tracker?'<span class="good">Found</span>':'<span class="bad">Not Found</span>',n+='</div></section><section><span class="label">Solars Panels:</span><div class="content"><span class="'+(e.connected_panels?"good":"bad")+'">'+e.connected_panels+" Connected</span></div></div></article>"},TMPL.space_heater=function(e,s,a){var n='<article class="display"><header><h2>Status</h2></header><section><span class="label">Power:</span><div class="content">'+a.link("On","power-off","power",null,e.on?"selected":null)+a.link("Off","close","power",null,e.on?null:"selected")+'</div></section><section><span class="label">Stored Energy:</span><div class="content">';return n+=e.hasPowercell?""+a.bar(e.powerLevel,0,100,"good",e.powerLevel+"%"):'<span class="bad">No power cell loaded.</span>',n+="</div></section>",e.open&&(n+='<section><span class="label">Cell:</span><div class="content">',n+=e.hasPowercell?""+a.link("Eject","eject","ejectcell"):""+a.link("Install","eject","installcell"),n+="</div></section>"),n+='</article><article class="display"><header><h2>Thermostat</h2></header><section><span class="label">Current Temp:</span><div class="content"><span>'+e.currentTemp+'&deg;C</span></div></section><section><span class="label">Target Temp:</span><div class="content"><span>'+e.targetTemp+"&deg;C</span></div></section>",e.open&&(n+='<section><span class="label">Adjustment:</span><div class="content">'+a.link("","fast-backward","temp",{set:-20},e.targetTemp>e.minTemp?null:"disabled")+a.link("","backward","temp",{set:-5},e.targetTemp>e.minTemp?null:"disabled")+a.link("Set","pencil","temp",{set:"custom"},null)+a.link("","forward","temp",{set:5},e.targetTemp<e.maxTemp?null:"disabled")+a.link("","fast-forward","temp",{set:20},e.targetTemp<e.maxTemp?null:"disabled")+"</div></section>"),n+='<section><span class="label">Operational Mode:</span><div class="content">',n+=e.open?""+a.link("Heat","long-arrow-up","mode",{mode:"heat"},"heat"!=e.mode?null:"selected")+a.link("Cool","long-arrow-down","mode",{mode:"cool"},"cool"!=e.mode?null:"selected")+a.link("Auto","arrows-v","mode",{mode:"auto"},"heat"==e.mode||"cool"==e.mode?null:"selected"):"heat"==e.mode?'<span class="bad">Heat</span>':"cool"==e.mode?'<span class="highlight">Cool</span>':'<span class="good">Auto</span>',n+="</div></section></article>"},TMPL.tanks=function(e,s,a){var n='<article class="notice">';return n+=e.hasHoldingTank?"<span>The regulator is connected to a mask.</span>":"<span>The regulator is not connected to a mask.</span>",n+='</article><article class="display"><section><span class="label">Tank Pressure:</span><div class="content">'+a.bar(e.tankPressure,0,1013,e.tankPressure>200?"good":e.tankPressure>100?"average":"bad",e.tankPressure+" kPa")+'</div></div><section><span class="label">Release Pressure:</span><div class="content">'+a.bar(e.releasePressure,e.minReleasePressure,e.maxReleasePressure,null,e.releasePressure+" kPa")+'</div></section><section><span class="label">Pressure Regulator:</span><div class="content">'+a.link("Reset","refresh","pressure",{set:"reset"},e.releasePressure!=e.defaultReleasePressure?null:"disabled")+a.link("Min","minus","pressure",{set:"min"},e.releasePressure>e.minReleasePressure?null:"disabled")+a.link("Set","pencil","pressure",{set:"custom"},null)+a.link("Max","plus","pressure",{set:"max"},e.releasePressure<e.maxReleasePressure?null:"disabled")+'</div></section><section><span class="label">Valve:</span><div class="content">'+a.link("Open","unlock","valve",null,e.maskConnected?e.valveOpen?"selected":null:"disabled")+a.link("Close","lock","valuve",null,e.valveOpen?null:"selected")+"</div></section></article>"},TMPL._generic=function(e,s,a){var n="<div id='container' class='container'> <header id='titlebar' class='titlebar' unselectable='on'> <i class='statusicon fa fa-eye fa-2x' unselectable='on'></i> <span class='title' unselectable='on'>"+s.title+"</span> <i class='minimize fancy fa fa-minus fa-2x' unselectable='on'></i> <i class='close fancy fa fa-close fa-2x' unselectable='on'></i> </header> <div id='content' class='content titlebared resizeable' unselectable='on'> <div class='loading'>Initiating...</div> </div> <div id='resize' class='resize fancy' unselectable='on'></div></div>";return n},TMPL._nanotrasen=function(e,s,a){var n="<div id='container' class='container'> <header id='titlebar' class='titlebar' unselectable='on'> <i class='statusicon fa fa-eye fa-2x' unselectable='on'></i> <span class='title' unselectable='on'>"+s.title+"</span> <i class='minimize fancy fa fa-minus fa-2x' unselectable='on'></i> <i class='close fancy fa fa-close fa-2x' unselectable='on'></i> </header> <div id='content' class='content titlebared resizeable' unselectable='on'> <div class='loading'>Initiating...</div> </div> <div id='resize' class='resize fancy' unselectable='on'></div></div>";return n};