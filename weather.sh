#!/bin/bash
# DIPENDENZE: bash - curl - wget
SERVER='http://techmagyor.net46.net/gweather'
#SERVER='CARO THEPASTO METTICI ANCHE IL TUO EHEH'
gwpath=$HOME/.gweather-conky
cd $gwpath/
# Aggiungere Iconsets per permettere scelta e far fare la scelta all'utente tramite menu testuale (quando le avremo) sia per l'installazione iniziale sia per quando voglia prendere altre iconsets
# usare zenity(?) oppure gtk oppure java per la prima configurazione o per la riconfigurazione localita'/linguaggio/cambio iconset
# Magari prendere icone a differenti risolzuoni: 16x16,24x24, 32x32x,64x64; magari di uno stesso tema offriamo diverse icone
# Aggiungere allora la versione delle iconsets affinche' si possano aggiornare
# Dovremmo cercare un metodo affinche' non subiamo l'update interval di conky ma forziamo il nostra; quando noi cambiamo (e magari rimpiazziamo l'icona dato che il tempo metereologico e' cambiato) conky lo cambiera' di conseguenza in seguito al suo update_interval, o no?
# Vedere se e' possibile non usare il mio server perche' sono tirchio; 
# Penso che dovremmo riscrivere quasi tutte le funzioni, se non altro esteticamente fanno abbastanza schifo...tant'e' che ora poi si vedra'

#### SE HO SCRITTO UN MONTE DI BOIATE UNTOFFENDE e' che poi me ne scordo quindi, meglio abbondare che deficiere diceva il grassottelo





############# ATTENZIONEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE###############################

#IN //WEEK CONDITION NEL TUO gweather_wrp.php PER FAR ANDARE FORECAST CON LA FORMATTAZIONE CORRETTA BISOGNA CAMBIA:

#		$fore=$fore.$icon."-".$day."-".$cond."-".$temp_h.$temp_l."-"."\n";

# e cmq guardalo meglio perche' vengono sformattati in .forecast le icone di UNO spazio

# poi pe fa vede le icone a conky servono i percorsi interi, ma il nostro e' gweather-config... eheh quindi ho messo -- 


#	return("$gwpath/ccicons/".$ico); riga 3

#	return ($icon."--".$cur_con."--".$cur_temp."--".$cur_hum."--".$cur_wind); riga 31

#	$fore=$fore.$icon."--".$day."--".$cond."--".$temp_h.$temp_l."--"."\n"; riga 45

##########################################################################################

#Se qualsiasi cosa non ti paice cambia e stravolgi come cazzo ti pare, il princio e' questo

#AGGIORNAMENTO PRIMA DI ANDA ALLETTO

#${execp image ${exec awk 'NR==1' $gwpath/.forecast}}
#${image $gwpath/ccicons/mostly_sunny.png}


#Per le immagini in conky
#nonostante il percorso sia corretto conky non mi renderizza l'immagine se chiamata con exec awk, invece se gli do il percorso a 'mano' ca che e' uan bellezza; quindi una soluzione puo' essere di creare due cartelle conndATTUALE e forecastATTUALE e copiarci le icone dentro con nomi tipo (x condATTUALE) condizioneattuale.png e passargliela a mano a conky, fare lo stesso per forecastATTUALE dargli tre nomi tipo domani.png dopodomani.png e il giornodopoancora.png e passarli a mano se conky non se li prende. cosi' si risolverebbe il discorso delle immagini....io dormo ; resta da vedere cmq se le cambia dopo che c'e' stato un aggiornamento...MAH

#AGGIORNAMENTO
#Ora le immagini sono fisse e cambiano di volta in volta che si aggiorna lo script e le mette nella cartella actuallicons. ci sarebbe da snellire e usare ottimizza davvero, ma insomma ora va per conky.ciao
		

#---------------------------------------------------------------------------------------------------------------------------#

#Serve per prima configurazione oppura chiamata da reconfigure
function configure_first {
	if  [ ! -s  gweather-config ]; then
	touch gweather-config
	echo "Insert your ZIP CODE of the city and the National Code to check weather (I.E. 34021,IT):"
	read input_city
	echo "Insert the language of the weather (I.E. en, fr, es) NOTE: not every language is available"
	read input_lang
	echo -e "\n"	
	CHECKLOC=$(curl -s "$SERVER/gweather_wrp.php?city=$input_city&lang=$input_lang&q=getLoc") #Controllo esistenza
	 if [ -z "$CHECKLOC" ]; then 
			echo "Cannot find any suitable location/language. Please try again" #Esco se non ho stream
			exit 0
	fi
	echo $CHECKLOC
	echo -e "\n"
	while true; do
    		 read -p "Is that suitable for you (y/n)? NOTE: not every location/language is available " yn
    		case $yn in
        		[Yy]* )  rm gweather-config
				      echo -e "\n"
				      echo city=$input_city >> gweather-config
				      echo lang=$input_lang >> gweather-config
					echo -e "Stored, HAVE FUN!!!\n";	
					usage #dopo prima configurazione o riconfigurazioni fa vedere Help Menu			 
					break ;;
        		[Nn]* ) exit;;
    	esac
done
	fi
}

#Serve per cambiare localita'/lingua
function reconfigure {
	echo -e "Reconfiguring Location/Languages now\n"
	rm gweather-config	
	configure-first
}

#Installa le icone
function install_conky_weather_icons {
	if [ ! -d ccicons ]; then
		echo "Downloading Default Icon Set"
		mkdir -p ccicons/
			for f in $(curl -s $SERVER/icon_list.php);do wget -P ccicons/  $SERVER/myweather/$f -O ccicons/$f >/dev/null 2>&1;done
		if [  ! -e gwtempl  ]; then
			touch gwtempl
			echo '${image [current] -p 90,70 -s 78x78}' >> gwtempl
			echo '${image [forec1] -p 20,170 -s 40x40 }' >> gwtempl
			echo '${image [forec2] -p 70,170 -s 40x40 }' >> gwtempl
			echo '${image [forec3] -p 120,170 -s 40x40 }' >> gwtempl
			echo '${image [forec4] -p 170,170 -s 40x40 }' >> gwtempl
			echo Setting static gwtemparser
		fi
		exit 1
	fi
}
 
#Help Menu
usage() {
        echo "
usage: $0 options
 
-c      Return Current Condition
 
-f       Retun Forecasts
 
-l       Return Location
 
-h      Dysplay this message
 
-v      Current Version

-i       Line to insert in conky already configured with themes and icon-set

-r	  Reconfigure you City Location and Display Language
 
"
}
 
 #versione
version () {
 
echo -e "\n \t gweather v.0.0.1montecitorio \n"
 
}

if [ ! -d actualicons ]; then
		mkdir actualicons
	else 	
		rm -rf actualicons && mkdir actualicons
	fi

# Localita' attuale & Costruzione icone per richiamarle con path fisso da conky
function getURLloc {
        echo  $(curl -s "$SERVER/gweather_wrp.php?$CITY&$LANG&q=$Q" "\n" )
	
}
 
# Meteo attuale
function getURLcurrentcond {
	if [ ! -s $gwpath/.currentcond ]; then
		touch $gwpath/.currentcond
	else 	
		rm $gwpath/.currentcond && touch .currentcond
	fi
	cond=$(curl  -s "$SERVER/gweather_wrp.php?$CITY&$LANG&q=$Q")
	
	echo $cond | gawk -F "--" '{print $1}' >> .currentcond
	echo $cond | gawk -F "--" '{print $2}' >> .currentcond
	echo $cond | gawk -F "--" '{print $3}' >> .currentcond	
	echo $cond | gawk -F "--" '{print $4}' >> .currentcond
	echo $cond | gawk -F "--" '{print $5}' >> .currentcond
}

 #Previsioni meteo per giorni seguenti, da formattare meglio nei file prima che in conky
function getURLforecast {
	if [ ! -s $gwpath/.forecast ]; then
		touch $gwpath/.forecast	
	else
		rm $gwpath/.forecast && touch $gwpath/.forecast
	fi
	fore=$(curl  -s "$SERVER/gweather_wrp.php?$CITY&$LANG&q=$Q")
	echo $fore | gawk -F "--" '{print $1}' >> .forecast
	echo $fore | gawk -F "--" '{print $2}' >> .forecast
	echo $fore | gawk -F "--" '{print $3}' >> .forecast
	echo $fore | gawk -F "--" '{print $4}' >> .forecast
	echo $fore | gawk -F "--" '{print $5}' >> .forecast
	echo $fore | gawk -F "--" '{print $6}' >> .forecast
	echo $fore | gawk -F "--" '{print $7}' >> .forecast
	echo $fore | gawk -F "--" '{print $8}' >> .forecast
	echo $fore | gawk -F "--" '{print $9}' >> .forecast
	echo $fore | gawk -F "--" '{print $10}' >> .forecast	
	echo $fore | gawk -F "--" '{print $11}' >> .forecast
	echo $fore | gawk -F "--" '{print $12}' >> .forecast
	echo $fore | gawk -F "--" '{print $13}' >> .forecast
	echo $fore | gawk -F "--" '{print $14}' >> .forecast
	echo $fore | gawk -F "--" '{print $15}' >> .forecast
	echo $fore | gawk -F "--" '{print $16}' >> .forecast
}

#Crea le linee da mettere dentro conky prendendole dai file esistenti, secondo uno schema standard; se va in futuro possiamo creare anche temi da scaricare in piu'.. MAH
function getCONFtoConky {
	 if [ ! -s gweather-config ]; then       #se file esiste ed 'e maggiore di zero
		echo "gweather is not confgured yet. Run ./weather.sh -r to configure now"	
		else 

		select CHOICE in Standard  Modern Personalize
			do
		case "$CHOICE" in
				"Standard") #quando entra qui la roba standard per funzionare c'e'
					echo -e "Standard conky theme configuration & replace the current icons withe standard ones"
					echo -e "Insert these lines on your ~./conkyrc :\n (for correct/well visalization enlarge you terminal window)"
					echo -e '${execpi 500 ~/.gweather-conky/weather.sh -p} #Set standard formatted theme forecas\n'					
					echo -e "Downloading and setting standard iconset"
					#serve un controllo per vedere quali icone attualmente sono installate
					#for f in $(curl -s $SERVER/icon_list.php);do wget -P ccicons/  $SERVER/myweather/$f -O ccicons/$f >/dev/null 2>&1;done		
					exit 0
					;;
				"Modern")
					echo -e "Modern theme conky configuration & replace currenticons with modern ones"
					echo -e "Insert these lines on your ~./conkyrc :\n (for correct/well visalization enlarge you terminal window)"
					echo -e "TO DO"
					echo -e "Downloading and setting Modern iconset"
					#serve un controllo per vedere quali icone attualmente sono installate
					#for f in $(curl -s $SERVER/icon_list2.php);do wget -P ccicons/  $SERVER/myweather2/$f -O ccicons/$f >/dev/null 2>&1;done	
					exit 0
					;;
				"Personalize")	
					echo -e "Insert these lines on your ~./conkyrc :\n (for correct/well visalization enlarge you terminal window)"
					echo -e "Personaliza your own conky lines with all usage conky function. To change icon theme only select Standard or Modern"
					echo '${execi 3600 $gwpath/weather.sh -l} #Actual Location'
					#echo '$(execi 3600 echo $(awk 'NR==1' $gwpath/.forecast))'			
					echo -e '${image ~/.gweather-conky/ccicons/cloudy.png -p 90,70 -s 78x78 } # Today Icon'
					echo -e '${image ~/.gweather-conky/ccicons/mostly_sunny.png -p 20,170 -s 40x40 } # Tomorrow Icon'
					echo -e '${image ~/.gweather-conky/ccicons/mostly_sunny.png -p 70,170 -s 40x40 } # Secondo day Icon'
					echo -e '${image ~/.gweather-conky/ccicons/sunny.png -p 120,170 -s 40x40 } # Third day Icon'
					echo -e '${image ~/.gweather-conky/ccicons/chance_of_rain.png -p 170,170 -s 40x40 } # Forth day Icon'	
					#echo $(awk 'NR==2' $gwpath/.forecast)
					#echo $(awk 'NR==3' $gwpath/.forecast)
					#echo $(awk 'NR==4' $gwpath/.forecast)
					#echo $(awk 'NR==5' $gwpath/.forecast)
					#echo $(awk 'NR==6' $gwpath/.forecast)
					#echo $(awk 'NR==7' $gwpath/.forecast)
					#echo $(awk 'NR==8' $gwpath/.forecast)
					#echo $(awk 'NR==9' $gwpath/.forecast)
					#echo $(awk 'NR==10' $gwpath/.forecast)
					#echo $(awk 'NR==11' $gwpath/.forecast)
					#echo $(awk 'NR==12' $gwpath/.forecast)
					#echo $(awk 'NR==13' $gwpath/.forecast)
					#echo $(awk 'NR==14' $gwpath/.forecast)
					#echo $(awk 'NR==15' $gwpath/.forecast)
					#echo $(awk 'NR==16' $gwpath/.forecast)
					exit 0
					;;
		esac
	done
		fi
}


configure_first

function parser {
	cur=$(cat $gwpath/.currentcond | grep ".png")
	forecs=$(cat $gwpath/.forecast | grep '.png')
	forecs=$(echo $forecs | sed 's:/:\\\/:g')
	cur=$(echo $cur | sed 's:/:\\\/:g')	
	picons=$(cat $gwpath/gwtempl)	
	a="1";
	foricon=$picons
	for c in $forecs 
	do
		foricon=$(echo $foricon | sed s/\\[forec$a[^\]]*\\]/$c/g)
		(( a++ ))
	done
	foricon=$(echo $foricon | sed s/\\[current[^\]]*\\]/$cur/g)
	echo $foricon
}

#Le inizializzo qui altrimenti se le metto all'inizo alla prima configurazione genereranno errore di esistenza, ma vanno bene uguale perche' nessuno le chiama prima di qui
LANG=$(cat $gwpath/gweather-config | grep lang)
CITY=$(cat $gwpath/gweather-config | grep city)

install_conky_weather_icons
 
#menu scelta per help menu passato da paramentro in bash
while getopts "cfhlpvir" OPTION
do
     case $OPTION in
         c)	
                Q='getCurrentCond'
                getURLcurrentcond      
             ;;
 
        f)
             Q='getForecast'
                getURLforecast
             ;;
             
         l)    
                Q='getLoc'
                getURLloc
             ;;
         h)
             usage
             exit 1
             ;;
         i) 	
		getCONFtoConky
		exit 0
	     ;;
         v) 
	      version
             exit 0
             ;;

	r) 
	    reconfigure
	    exit 0
	    ;;

	p) 
	   parser
	   exit 0
	   ;; 

        ?)
             usage
             exit 1
             ;;
	
     esac
done
 
# se $Q e' vuota cioe' senza paramentro da bash allora verra' interpretato come usage
if [[ -z $Q ]]
then
     usage
     exit 1
fi
