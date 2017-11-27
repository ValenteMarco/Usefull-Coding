global with sharing class AutoCompleteController2 {
    public boolean showmap{get;set;}
    public Sede_impianto__c sedeImpianto{get;set;}
    public string erroreComune {get;set;}
    public string erroreIndirizzo{get;set;}
    public string errorecivico{get;set;}
    public AutoCompleteController2(){
      sedeImpianto=new Sede_impianto__c();
      sedeImpianto.IdGruppoVie__c='';
      sedeImpianto.IdGruppoComuni__c='';
      sedeImpianto.IdGruppoCivici__c='';
      showmap=false;
    }

    public AutoCompleteController2(ApexPages.StandardController controller){
      sedeImpianto= (Sede_Impianto__c) controller.getRecord();
      sedeImpianto.IdGruppoVie__c='';
      sedeImpianto.IdGruppoComuni__c='';
      sedeImpianto.IdGruppoCivici__c='';
      showmap=false;
      Map<String, String> parameters=ApexPages.currentPage().getParameters();
      for(String key:parameters.keySet())
      {
        if(key.endsWith('_lkid'))
        if(!parameters.get(key).startswith('00Q'))
          sedeImpianto.account__c=parameters.get(key);
        else
         sedeImpianto.lead__c=parameters.get(key);
      }
    }

    public PageReference updateSede()
    {
        System.debug('@@@@ sede scelta '+sedeImpianto);
        return null;
    }


    @RemoteAction
    global static SObject[] richiamaWS(String ricerca, String indicazioneWS, String idgc, String idgv,String idgcivico) {

        if ( indicazioneWS == 'comune' ){
            //richiamo WS comune
           System.debug('RicercaComune: '+ricerca);
            //writeXmlAvtGetComuni(ricerca);
           return parseXmlComuniNew(ricerca);
        }else{
            if (indicazioneWS == 'via'){
                //richiamo WS via
                system.debug('idgcWs: '+idgc);

                    return parseXmlVieNew(idgc, ricerca);
            }else{
                //richiamo WS civico

                    return parseXmlCiviciNew(ricerca,idgv);
                }
        }
        return null;
    }

    // GENERAZIONE XML FAKE SinonimoIndirizzo
    public static String xmlAvtGetSinonimoIndirizzo(){
        return '<return><provincia>MI</provincia><comune>MILANO</comune><toponimo>VIALE</toponimo><nomeVia>FULVIO TESTI</nomeVia><civico>100</civico><cap>20126</cap></return>';
    }
    // FINE REMOVE



    public static List<Sobject> parseXmlComuniNew(String ricerca){
        try{
            NE__IntegrationAdministration__c admin = [SELECT NE__CertificateName__c,NE__Password__c,NE__Username__c,NE__EndPoint__c,NE__Timeout__c,NE__Name__c FROM NE__IntegrationAdministration__c WHERE NE__Name__c = 'RicercaCoperturaService'];
            RicercaCoperturaService.RicercaCoperturaServicePort RicercaCoperturaService = new   RicercaCoperturaService.RicercaCoperturaServicePort();
            RicercaCoperturaService.endpoint_x   = admin.NE__EndPoint__c;
            RicercaCoperturaService.timeout_x   = Integer.valueof(admin.NE__Timeout__c);
            RicercaCoperturaService.inputHttpHeaders_x  =  new Map<String, String>();
            RicercaCoperturaService.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(blob.valueof(admin.NE__Username__c+':'+admin.NE__Password__c)));

            RicercaCoperturaService.ParametersType  ParametersType = new RicercaCoperturaService.ParametersType();
            ParametersType.caller = 'PWS';

            RicercaCoperturaService.ChiaveRicercaType  ChiaveRicercaType  = new RicercaCoperturaService.ChiaveRicercaType  ();
            ChiaveRicercaType.chiave = ricerca;

            RicercaCoperturaService.RicercaComuneResponseType test = RicercaCoperturaService.RicercaComune(ParametersType, ChiaveRicercaType);
            system.Debug('testws: '+test.listaComuni);

            List <Sede_impianto__c> sediTornate = new List <Sede_impianto__c> ();


           for(RicercaCoperturaService.ComuneType com: test.listaComuni.comune){
                Sede_impianto__c sede = new Sede_impianto__c();
                sede.IdGruppoComuni__c  = com.idComune;
                sede.Sigla_provincia__c = com.siglaProvincia;
                sede.Citt__c            = com.nomeComune;
                sede.Codice_ISTAT__c    = com.codiceISTAT;
                //sede.Cap__c             = com.capComune; //??? nuovo campo capComune
                //sede.PrefissoComune__c  = com.prefissoComune;
                sediTornate.add(sede);
            }



            System.debug('sediTornateDaComuni' + sediTornate);
            return sediTornate;
        }catch(Exception e){
            System.debug('Exception' + e);
            return null;
        }
    }


    public static List<Sobject> parseXmlVieNew(String idgc, String ricerca){
        try{
            system.debug('idgc: '+idgc);
            NE__IntegrationAdministration__c admin = [SELECT NE__CertificateName__c,NE__Password__c,NE__Username__c,NE__EndPoint__c,NE__Timeout__c,NE__Name__c FROM NE__IntegrationAdministration__c WHERE NE__Name__c = 'RicercaCoperturaService'];
            RicercaCoperturaService.RicercaCoperturaServicePort RicercaCoperturaService = new   RicercaCoperturaService.RicercaCoperturaServicePort();
            RicercaCoperturaService.endpoint_x   = admin.NE__EndPoint__c;
            RicercaCoperturaService.timeout_x   = Integer.valueof(admin.NE__Timeout__c);
            RicercaCoperturaService.inputHttpHeaders_x  =  new Map<String, String>();
            RicercaCoperturaService.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(blob.valueof(admin.NE__Username__c+':'+admin.NE__Password__c)));

            RicercaCoperturaService.ParametersType  ParametersType = new RicercaCoperturaService.ParametersType();
            ParametersType.caller = 'PWS';

            RicercaCoperturaService.ChiaveRicercaType  ChiaveRicercaType  = new RicercaCoperturaService.ChiaveRicercaType  ();
            ChiaveRicercaType.chiave = ricerca;
            ChiaveRicercaType.idParent = idgc;

             RicercaCoperturaService.RicercaViaResponseType vieResponse = RicercaCoperturaService.RicercaVia(ParametersType, ChiaveRicercaType);
            system.Debug('testws: '+vieResponse.listaVie);

            List <Sede_impianto__c> sediTornate = new List <Sede_impianto__c> ();
            for(RicercaCoperturaService.ViaType via: vieResponse.listaVie.via){
                Sede_impianto__c sede = new Sede_impianto__c();
                //String denominazione = via.denominazione;
                //String nomeVia =    via.nomeVia;
                sede.IdGruppoVie__c =   via.idVia;
                sede.Particella__c = via.toponomasticaVia;
                sede.Indirizzo__c = via.nomeVia;
                sede.Cap__c = via.capVia; //??? nuovo campo capVia
                sediTornate.add(sede);
            }

            system.debug('sediTornateDaVie' + sediTornate);
            return sediTornate;
        }catch(Exception e){
            System.debug('Exception' + e);
            return null;
        }
    }


    public static List<Sobject> parseXmlCiviciNew(String ricerca, String idgv){
        try{
            system.debug('idgv: '+idgv);
            NE__IntegrationAdministration__c admin = [SELECT NE__CertificateName__c,NE__Password__c,NE__Username__c,NE__EndPoint__c,NE__Timeout__c,NE__Name__c FROM NE__IntegrationAdministration__c WHERE NE__Name__c = 'RicercaCoperturaService'];
            RicercaCoperturaService.RicercaCoperturaServicePort RicercaCoperturaService = new   RicercaCoperturaService.RicercaCoperturaServicePort();
            RicercaCoperturaService.endpoint_x   = admin.NE__EndPoint__c;
            RicercaCoperturaService.timeout_x   = Integer.valueof(admin.NE__Timeout__c);
            RicercaCoperturaService.inputHttpHeaders_x  =  new Map<String, String>();
            RicercaCoperturaService.inputHttpHeaders_x.put('Authorization', 'Basic '+EncodingUtil.base64Encode(blob.valueof(admin.NE__Username__c+':'+admin.NE__Password__c)));

            RicercaCoperturaService.ParametersType  ParametersType = new RicercaCoperturaService.ParametersType();
            ParametersType.caller = 'PWS';

            RicercaCoperturaService.ChiaveRicercaType  ChiaveRicercaType  = new RicercaCoperturaService.ChiaveRicercaType  ();
            ChiaveRicercaType.chiave = ricerca;
            ChiaveRicercaType.idParent = idgv;

             RicercaCoperturaService.RicercaCivicoResponseType civicoResponse= RicercaCoperturaService.RicercaCivico(ParametersType, ChiaveRicercaType);
            system.Debug('testws: '+civicoResponse.listaCivici);

            List <Sede_impianto__c> sediTornate = new List <Sede_impianto__c> ();
            for(RicercaCoperturaService.CivicoType civico: civicoResponse.listaCivici.Civico){
                Sede_impianto__c sede  = new Sede_impianto__c();
                sede.IdGruppoCivici__c = civico.idCivico;
                sede.Numero_civico__c  = civico.numeroCivico;
                sede.Civico__c         = civico.numeroCivico;
                System.debug('@numero civico'+civico.numeroCivico);
                System.debug('@esponente civico'+civico.esponenteCivico+'*');
                if(civico.esponenteCivico.replaceAll(' ','')!='' && civico.esponenteCivico.replaceAll(' ','')!=null){
                    sede.Numero_civico__C   += '/'+civico.esponenteCivico.replaceAll(' ','');
                    sede.Esponente_Civico__c = civico.esponenteCivico.replaceAll(' ','');
                }
                sede.Indirizzo_Normalizzato__c = true;
                sede.Nuova_Copertura__c = true;
                system.debug('Risorse: '+civico.listaRisorse.risorsa);
                if(civico.listaRisorse.risorsa!=null){
                    for(RicercaCoperturaService.RisorsaType risorsa: civico.listaRisorse.risorsa){
                        if(risorsa.tipoRisorsa == 'SGU'){
                            sede.Codice_Vendibilit__c = risorsa.idRisorsa;
                        }
                        else if(risorsa.tipoRisorsa == 'SGU_FTTS') {
                            sede.FW_Id_SGUFTTS__c = risorsa.idRisorsa;
                        }
                        else if(risorsa.tipoRisorsa == 'CABINET'){
                            sede.FW_Id_Cabinet__c = risorsa.idRisorsa;
                        }
                        else if(risorsa.tipoRisorsa == 'TIPOELEMENTO'){
                            sede.Tipo_Elemento__c = risorsa.idRisorsa;
                        }
                    }
                }
                sediTornate.add(sede);
            }

            system.debug('sediTornateDaCivici' + sediTornate);
            return sediTornate;
        }catch(Exception e){
            System.debug('parseXmlCiviciNew Exception' + e);
            return null;
        }
    }
    // PARSING XML SinonimoIndirizzo E GENERAZIONE LISTA VALORI  TORNATI DA WSDL
    public static List<Sobject> parseXmlSinonimoIndirizzo(){
        try{
            List <Sede_impianto__c> sediTornate = new List <Sede_impianto__c> ();
            String expectedResult = xmlAvtGetSinonimoIndirizzo();  // TO DO REMOVE
            dom.Document doc= new dom.Document();
            doc.load(expectedResult);
            dom.XmlNode rootElement = doc.getRootElement();
            for(dom.XmlNode sinonimo : rootElement.getChildElements()){
                Sede_impianto__c sede = new Sede_impianto__c();
                sede.Provincia__c       =   sinonimo.getChildElement('provincia',null).getText();
                sede.Citt__c            =   sinonimo.getChildElement('comune',null).getText();
                sede.Particella__c      =   sinonimo.getChildElement('toponimo',null).getText();
                sede.Indirizzo__c       =   sinonimo.getChildElement('nomeVia',null).getText();
                sede.Numero_civico__c   =   sinonimo.getChildElement('civico',null).getText();
                sede.CAP__c             =   sinonimo.getChildElement('cap',null).getText();
                sediTornate.add(sede);
            }
            system.debug('sediTornateDaSinonimi' + sediTornate);
            return sediTornate;
        }catch(Exception e){
            System.debug('Exception' + e);
            return null;
        }
    }

    public PageReference getCoordinateAndCoverage(){
      NE__IntegrationAdministration__c adminCoordinate = [SELECT NE__CertificateName__c, NE__Password__c, NE__Username__c, NE__EndPoint__c, NE__Timeout__c, NE__Name__c FROM NE__IntegrationAdministration__c WHERE NE__Name__c = 'RicercaCoperturaService'];
      //Coordinate geografiche
      RicercaCoperturaService.RicercaCoperturaServicePort  RicercaCoperturaService = new RicercaCoperturaService.RicercaCoperturaServicePort();
            RicercaCoperturaService.endpoint_x = adminCoordinate.NE__EndPoint__c;
            RicercaCoperturaService.timeout_x = Integer.valueof(adminCoordinate.NE__Timeout__c);
            RicercaCoperturaService.inputHttpHeaders_x = new Map < String, String > ();
            RicercaCoperturaService.inputHttpHeaders_x.put('Authorization', 'Basic ' + EncodingUtil.base64Encode(blob.valueof(adminCoordinate.NE__Username__c + ':' + adminCoordinate.NE__Password__c)));
            RicercaCoperturaService.ParametersType ParametersType = new RicercaCoperturaService.ParametersType();
            ParametersType.caller = 'PWS';
            RicercaCoperturaService.CoordinateChiaveRicercaType CoordinateChiaveRicercaType = new RicercaCoperturaService.CoordinateChiaveRicercaType();
            CoordinateChiaveRicercaType.idComune = SedeImpianto.idGruppoComuni__c;
            CoordinateChiaveRicercaType.idVia = SedeImpianto.idGruppoVie__c;
            CoordinateChiaveRicercaType.idCivico = SedeImpianto.idGruppoCivici__c;
            RicercaCoperturaService.coordinateFromIdResponseType coordinateResponse = RicercaCoperturaService.getCoordinateFromId(ParametersType, CoordinateChiaveRicercaType);
            RicercaCoperturaService.resultType coordinateResult = coordinateResponse.resultType;
      showmap=false;
      if (coordinateResult.errorCode == '0')
            {
                RicercaCoperturaService.datiCoordinateType datiCoordinate = coordinateResponse.datiCoordinate;
                /*SedeImpianto.LatitudineMetri__C = datiCoordinate.coordYmetri.replace(',','.');
                SedeImpianto.LongitudineMetri__C = datiCoordinate.coordXmetri.replace(',','.');*/
                SedeImpianto.LatitudineGradi__C = datiCoordinate.coordYgradi.replace(',','.');
                SedeImpianto.LongitudineGradi__C = datiCoordinate.coordXgradi.replace(',','.');
        showmap=true;
            }
      //copertura
      RicercaCoperturaService.ParametersType parametri = new RicercaCoperturaService.ParametersType();
                parametri.caller = 'PWS';
                String idCivico = SedeImpianto.idGruppoCivici__c;
                String cabinet = SedeImpianto.FW_Id_Cabinet__c;
                String SGU_Ftts = SedeImpianto.Fw_Id_SGUFtts__c;
                String SGU = SedeImpianto.Codice_Vendibilit__c;
                String TIPOELEMENTO = SedeImpianto.Tipo_Elemento__c;
                system.debug('@@TipoELEMENTO: ' + SedeImpianto.Tipo_Elemento__c);
                List < RicercaCoperturaService.richiestaCoperturaType > ListaRicercaCopertura = new List < RicercaCoperturaService.richiestaCoperturaType > ();
                RicercaCoperturaService.richiestaCoperturaType ricercaCoperturaSgu = new RicercaCoperturaService.richiestaCoperturaType();
                ricercaCoperturaSgu.TipoRisorsa = 'SGU';
                ricercaCoperturaSgu.idRisorsa = SGU;
                RicercaCoperturaService.richiestaCoperturaType ricercaCoperturaCabinet = new RicercaCoperturaService.richiestaCoperturaType();
                ricercaCoperturaCabinet.TipoRisorsa = 'CABINET';
                ricercaCoperturaCabinet.idRisorsa = Cabinet;
                RicercaCoperturaService.richiestaCoperturaType ricercaCoperturaSGU_Ftts = new RicercaCoperturaService.richiestaCoperturaType();
                ricercaCoperturaSGU_Ftts.TipoRisorsa = 'SGU_FTTS';
                ricercaCoperturaSGU_Ftts.idRisorsa = SGU_Ftts;
                RicercaCoperturaService.richiestaCoperturaType ricercaCoperturaELEMENTO = new RicercaCoperturaService.richiestaCoperturaType();
                ricercaCoperturaELEMENTO.TipoRisorsa = 'TIPOELEMENTO';
                ricercaCoperturaELEMENTO.idRisorsa = TIPOELEMENTO;
                if (SGU != null && SGU != '') ListaRicercaCopertura.add(ricercaCoperturaSGU);
                if (Cabinet != null && Cabinet != '') ListaRicercaCopertura.add(ricercaCoperturaCabinet);
                if (SGU_Ftts != null && SGU_Ftts != '') ListaRicercaCopertura.add(ricercaCoperturaSGU_Ftts);
                if (TIPOELEMENTO != null && TIPOELEMENTO != '') ListaRicercaCopertura.add(ricercaCoperturaELEMENTO);
                //system.debug('TEST: '+RicercaCoperturaService.ricercaCoperturaPuntuale(parametri,idCivico,ListaRicercaCopertura));
                List < String > tecnoValue = new List < String > ();
                try
                {
                    RicercaCoperturaService.ricercaCoperturaPuntualeResponseType RicercaResponse = RicercaCoperturaService.ricercaCoperturaPuntuale(parametri, idCivico, ListaRicercaCopertura);
                    List < RicercaCoperturaService.datiCoperturaType > datiCopertura = RicercaResponse.response.datiCopertura;
                    RicercaCoperturaService.datiCentraleType datiCentrale = RicercaResponse.response.datiCentrale;
                    String errorCode = RicercaResponse.result.errorCode;
                    //se la chiamta ha avuto esito positivo
                    if (errorCode == '0')
                    {
                        for (RicercaCoperturaService.datiCoperturaType dato: datiCopertura)
                        {
                            //nuova Gestione SEMAFORI costruttore wrapper macroservizio, famiglia, semaforo, tecnologia
                            //wrapper = new MacroServizioWrapper(dato.macroservizio, dato.famigliaTecnologia, dato.semaforofamiglia, '');
                            //MappaServizio.put(wrapper.getChiave(), wrapper);
              System.debug('@@@@ dato '+dato);
                        }
                    }
                }
                catch (Exception e)
                {
                    System.debug('@Exception' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
                }
        return null;

    }
    
    public pagereference salva()
    {
        getCoordinateAndCoverage();
        upsert SedeImpianto;
        return new PageReference('/'+sedeimpianto.id);
    
    }
}