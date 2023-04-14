public class UnitService {
	  
	  //OBJETIVO: Insertar registros en objeto "User_Unidad__c" (Usuario Unidad Historial)
      //REQUISITOS: Tener listo los campos necesario para "Usuario Unidad", estos es
      		//Campos padres (Lookup & MasterDetail):
					//Unidad__c (Se tiene, pero necesitamos traerla por sus relaciones)
					//Usuario_Modulo__c (No se tiene)
					//User__c (Si se tiene:  UserInfo.getUserId())
			//Campos seteables (Que se puedan setear de una vez al momento de crear):
					//Estado__c
		    //Campos dependientes (que dependen de los otros registros):
		    		//NumeroIntentos__c
		    	
			//OPCIONAL Campos Hijos (IDs) Se insertan luego de insertar el Objeto principal:
					//Historial_Respuesta__c 
  @AuraEnabled (cacheable=false)			
  public static Boolean usuarioUnidadRegistrar(Id uId, String strJs) {
  			
//==================== Traer Unidad__c (Despues 2/user_Modulo__c) ====================
      		Unidad__c uRespondida = [SELECT (SELECT Id, Name FROM Preguntas__r), Modulo__c //Necesario para traer User_Modulo__r
                                     FROM Unidad__c WHERE Id = :uId WITH SECURITY_ENFORCED];
      		
//==================== Traer User_Modulo__c (Despues 1/User_Modulo__c) ==================== 
			/*
      		User_Modulo__c userModulo = null;		//Me permitira validar si es nulo
      		userModulo = [SELECT Id FROM User_Modulo__c 
                          WHERE Modulo__c=:uRespondida.Modulo__c AND Usuario__c=:UserInfo.getUserId()
                          AND Estado__c = 'En progreso'];      		
      					  //Validar User_Modulo__c || Crear User_Modulo__c 
                          if(userModulo==null){
                               userModulo = new User_Modulo__c(Usuario__c = UserInfo.getUserId(),
                                                               Modulo__c = uRespondida.Modulo__c,
                                                               Estado__c = 'En progreso');
                                 
                                //Insertamos userModulo para obtenet su Id
                                insert userModulo;
                           }    
      		*/
      
      		User_Modulo__c userModulo = null;
      		//st<User_Modulo__c> userModulos = new List<User_Modulo__c>();
      		List<User_Modulo__c> userModulos = [SELECT Id FROM User_Modulo__c 
                                                WHERE Modulo__c=:uRespondida.Modulo__c 
                                                AND Usuario__c=:UserInfo.getUserId()
                                                AND Estado__c = 'En progreso' WITH SECURITY_ENFORCED];
      
            if(userModulos.size() > 0) {
                // No se encontró ningún registro
                userModulo = userModulos[0];
                
            } else {
                // Se encontró al menos un registro
                userModulo = new User_Modulo__c(Usuario__c = UserInfo.getUserId(),
                                                               Modulo__c = uRespondida.Modulo__c,
                                                               Estado__c = 'En progreso');
                                 
                //Insertamos userModulo para obtenet su Id
                insert userModulo;
            }

      
//==================== Traer User_Unidad__c (Despues 3/NumeroIntentos__c) ====================
			List<User_Unidad__c> listaUserUnidad = new List<User_Unidad__c>();
			listaUserUnidad = [SELECT Id, NumeroIntentos__c
                			   FROM User_Unidad__c 
                               WHERE Unidad1__c=:uId AND Usuario__c=:UserInfo.getUserId()];      		     		
                            //Determinar la posicion en la lista del objeto con el mayor numero de intentos 
                            Integer maxIntento = -1;
                            if(!listaUserUnidad.isEmpty()){
                               for(User_Unidad__c userU : listaUserUnidad){
                                   if(userU.NumeroIntentos__c>maxIntento){	//Conversion implicita
                                        maxIntento = userU.NumeroIntentos__c.intValue();
                                   }
                               }
                            }

      		
			
      
      
            //Insertar User_Unidad__c
            User_Unidad__c uInsertada = new User_Unidad__c(Unidad1__c = uId,
                                                           User_Modulo__c = userModulo.Id,
                                                           Usuario__c = UserInfo.getUserId(),
                                                           Estado__c = 'Draft');
      		
      		//Insertar NumeroIntentos
      		if(!(maxIntento==-1)){
                uInsertada.NumeroIntentos__c = maxIntento + 1;
            }else{
                UInsertada.NumeroIntentos__c = 1;
            }
            
      		insert uInsertada;
            
			//Vincular a Historial_Respuesta__c   
            		//Insertar Historial_Respuesta__c
            		List<Historial_Respuesta__c> respuestaLista = new List<Historial_Respuesta__c>();
                	Map<Id, Id> p_r_Map = (Map<Id, Id>) JSON.deserialize(strJs,Map<Id, Id>.class);
      				
                    for(Pregunta__c pr:uRespondida.Preguntas__r){	
                        Historial_Respuesta__c respuesta= new Historial_Respuesta__c(Respuestas__c = p_r_Map.get(pr.Id),
                                                                                     User_Unidad__c = uInsertada.Id,
                                                                                     Pregunta__c = pr.Id);
                        respuestaLista.add(respuesta);
                    }
      				
      		insert respuestaLista;
            
      		//Cambiar el estatus del registro User_Unidad__c insertado
      		uInsertada.Estado__c = 'Answered';
      		update uInsertada;
      
      		return true;
  }
    
//================================= Clase TrailWrapper =================================   
  public class TrailWrapper {
      	@AuraEnabled
		public Trail__c trail; 
        //Registro de Trail solicitado
        @AuraEnabled
        public Integer progressTrail;								//Falta por calcular
        //Porcentaje de progreso del Alumno en el Trail

        //Módulos con Unidades relacionadas
        @AuraEnabled
        public List<Modulo__c> modules;
        @AuraEnabled
        public List<Id> passedModuleIds; 
        //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedUnitIds; 
        //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
        
      	//Constructor TrailWrapper
      	public TrailWrapper (Trail__c trail, List<Modulo__c> modules, List<Id> passedModuleIds, List<Id> passedUnitIds){
            				 this.trail = trail;
                             this.modules = modules;
                             this.passedModuleIds = passedModuleIds;
                             this.passedUnitIds = passedUnitIds;
        }      	 
	}
  
//================================= Metodo para obtener clase TrailWrapper =================================
  public TrailWrapper obtenerTrail(Id idTr){
         
   
//================================= Obtener Modulos y Unidades Relacionadas =================================
             					//Obtener Modulo_Trail__c
             					List<Trail_Modulo__c> lista_MT = [SELECT Modulo__c 
                                            					  FROM Trail_Modulo__c 
                                            					  WHERE Trail__c =: idTr];
                                
                                Set <Id> id_M = new Set <Id>();
      
                                for(Trail_Modulo__c mT : lista_MT){
                                    id_M.add(mT.Modulo__c);
                                }
             
             		List<Modulo__c> modules = [SELECT Name, Puntos__c, Tiempo1__c, Descripcion__c, Tipo_de_Modulo__c,
          											  (SELECT Name, Puntos__c, Tiempo__c, Contenido__c
                                                       FROM Unidades__r) 
                                               FROM Modulo__c WHERE Id IN : id_M];	//Se obtiene
             		
             		
             		
//================================= Obtener ID de User_Modulos Completados =================================
             		List<User_Modulo__c> lista_UM = [SELECT Modulo__c 
                                                     FROM User_Modulo__c WHERE Estado__c = 'Completado' 
                                                     AND Modulo__c IN : modules 
                                                     AND Usuario__c =: Userinfo.getUserId()];					
					
                    Set<Id> passedModuleIds = new Set<Id>();
             		
                    for(User_Modulo__c uM : lista_UM){
                        passedModuleIds.add(uM.Modulo__c);	//Se obtiene
                    }
                                 		
					
//================================= Obtener ID de User_Unidad Completadas =================================
					List<User_Unidad__c> lista_UU = [SELECT Unidad1__c 
                                      			     FROM User_Unidad__c 
                                      			     WHERE Estado__c = 'Success' 
                                      			     AND Usuario__c =: Userinfo.getUserId() 
                                      				 AND Unidad1__r.Modulo__c in : modules];
             
                    Set<Id> passedUnitIds = new Set<Id>();
      
                    for(User_Unidad__c uU : lista_UU){
                            passedUnitIds.add(uU.Unidad1__c);	//Se obtiene
                        }
                
                                  		
//================================= Obtener el Trail =================================
          			Trail__c trail = [SELECT Name, Puntos_Totales__c, Tiempo_Total__c, Descripcion__c, CantU__c
                                      FROM Trail__c WHERE Id =: idTr];
             
             		//Instanciar la clase TrailWrapper
          			TrailWrapper tr = new TrailWrapper(trail, modules, new List<Id>(passedModuleIds), new List<Id>(passedUnitIds));
        
         return tr;      
  }

//================================= Clase UnitWrapper =================================
  public class UnitWrapper {
        @AuraEnabled    
        public Unidad__c unit; //Unidad solicitada
        @AuraEnabled 
        public List <Pregunta__c> questions; // Lista de preguntas de la unidad
   
      	//Constructor UnitWrapper
        public UnitWrapper (Unidad__c unit, List<Pregunta__c> questions){
                            this.unit = unit;
            				this.questions = questions;
        }
  }
    
//================================= Metodo para obtener clase UntWrapper =================================
  @AuraEnabled (cacheable=true)
  public static UnitWrapper obtenerUnidad(Id idU){

//================================= Obtener Unidades y Preguntas Relacionadas =================================		
        Unidad__c unit = [SELECT Id, Name, Puntos__c, Tiempo__c, Contenido__c, 
                         		 (SELECT Id, Name, Contenido__c FROM Preguntas__r) 
                          FROM Unidad__c WHERE Id =: idU];		//Se obtiene

//================================= Obtener Preguntas y Respuestas Relacionadas =================================
        List<Pregunta__c> questions = [SELECT Id, Name, Contenido__c,
                                      		  (SELECT id, Name, Contenido_Respuesta__c, Es_Correcto__c 
                                               FROM Respuestas__r) 
                                       FROM Pregunta__c WHERE Unidad__c =: idU];		//Se obtiene

      	//Instancias UnitWrapper
        UnitWrapper u = new UnitWrapper(unit, questions);
        return u;
  }
    
}