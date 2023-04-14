public class isCorrectUnitTrigger {
    
    //Filtrar los campos que levantaran el trigger
	public static void filtrar(List<User_Unidad__c> newLista, List<User_Unidad__c> oldLista){
		
        //Map<Id, User_Unidad__c> oldMapList = new Map<Id, User_Unidad__c>(oldLista);
        List <User_Unidad__c> listaUU = new List <User_Unidad__c>();
        
        for(User_Unidad__c  uu : newLista){
            
            User_Unidad__c uu_old;
            for(User_Unidad__c uu1: oldLista){
                if(uu.Id == uu1.Id){
                    uu_old = uu1;
                }
            }
            /*
            if(oldMapList.get(uu.Id).Estado__c == 'Draft' && uu.Estado__c == 'Answered'){
            listaUU.add(uu);
            }
			**/
            if(uu_old.Estado__c == 'Draft' && uu.Estado__c == 'Answered'){
            	listaUU.add(uu);
        	}		
		}
        
        validarRespuestas(listaUU);
    }
    
    //Validar las respuestas correctas
    public static void validarRespuestas (List<User_Unidad__c> listaUU) {
        
        //Traemos Lista de User_Unidad__c y convertimos a mapa
        List<User_Unidad__c> listaUU_Completa = [SELECT Id, Unidad1__r.Puntos__c, Usuario__r.Id, 
                                                 	    User_Modulo__r.CantUniCom__c, 
                                                 		(SELECT Respuestas__r.Es_Correcto__c 
                                                  	     FROM Historial_Respuestas__r)
                                                 FROM User_Unidad__c WHERE Id IN: listaUU];
        
        Map<Id,User_Unidad__c> mapaUU = new Map<Id, User_Unidad__c>(listaUU_Completa);
        /*
        listUU_completada= {u1:{Id_u1:...,..}, u2:{Id_u2:...,..}, u3:{Id_u3:...,..}}
        mapaUU=(Id_u1:u1, Id_u2:u2, Id_u3:u3)
        */
        //Traemos Lista de User y convertimos a mapa
        List<User> listaUsers = [Select Id, Puntos__c, Rango__c FROM User];
        Map<Id, User> mapaUsers = new Map<Id, User>(listaUsers);
        
        //Creamos lista de User_Modulos__c
        List<User_Modulo__c> usuarios_modulos = new List<User_Modulo__c>();
        
        //Creamos lista de User
        List<User> usuarios = new List<User>();
        
        for (User_Unidad__c uu : listaUU){
             Integer incorrectas = 0;
             //Map<Id, User> mapaUsuarios = new Map<Id, User>(usuarios); 
             for (Historial_Respuesta__c respuesta : mapaUU.get(uu.Id).Historial_Respuestas__r) {                       
                  	if (respuesta.Respuestas__r.Es_Correcto__c != true){
                        incorrectas++;
                    }
             }
             if(incorrectas == 0){
                    uu.Estado__c = 'Success';    
                    if(uu.NumeroIntentos__c == 1){
                          uu.Puntos__c = mapaUU.get(uu.id).Unidad1__r.Puntos__c;
                    }else if(uu.NumeroIntentos__c == 2){
                          uu.Puntos__c = mapaUU.get(uu.id).Unidad1__r.Puntos__c/2;
                    }else{
                          uu.Puntos__c = mapaUU.get(uu.id).Unidad1__r.Puntos__c/4;
                    }
       
					//Actualizar User_Module__c
					mapaUU.get(uu.Id).User_Modulo__r.CantUniCom__c += 1;	
					usuarios_modulos.add(mapaUU.get(uu.Id).User_Modulo__r);                     
                 	
                 	//Actulizar los User
                 	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c += uu.Puntos__c;
                 
                 	if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 0 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 200){
                     	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'SCOUT';
                           
                 	}else if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 200 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 3000){
                     	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'HIKER';
                           
                 	}else if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 3000 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 9000){
                    	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'EXPLORER';
                           
                 	}else if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 9000 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 18000){
                     	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'ADVENTURER';
                           
                 	}else if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 18000 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 35000){
                     	mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'MOUNTAINEER';
                           
                 	}else if(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c >= 35000 && 
                       mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c < 50000){
                         mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'EXPEDITIONER';
                           
                    }else{
                      	 mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c = 'RANGER';
                        
                    }
                        
                     if(!usuarios.isEmpty()){
                         Integer bandera = 0;
                         for(User usur: usuarios){
                            if(usur.Id == mapaUU.get(uu.id).Usuario__r.Id){
                                usur.Puntos__c = mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Puntos__c;
                                usur.Rango__c = mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id).Rango__c;
                                bandera++;
                            }
                    	 }
                         if(bandera==0){
                            usuarios.add(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id));
                         }
                     }else{
                         usuarios.add(mapaUsers.get(mapaUU.get(uu.id).Usuario__r.Id));
                     }
                 	               	
              }else{
                    uu.Estado__c = 'Fail';
             }   
        }
        
        //Actualizar User actualizado
        if(!usuarios.isEmpty()){
            update usuarios;
        }
        
        //Actualizar Usuarios_Modulos__c
        if(!usuarios_modulos.isEmpty()){
            update usuarios_modulos;
        }
	}
    
}