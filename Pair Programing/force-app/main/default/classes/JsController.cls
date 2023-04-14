public class JsController {
    @AuraEnabled(cacheable=True)
    public static UnitService.TrailWrapper trail(Id idTr) {
        UnitService uS = new UnitService();
        return uS.obtenerTrail(idTr);
    }
}