export function calcularProgreso(passedUnitIds, CantU) {
    return Math.round((passedUnitIds.length / CantU) * 100);
}