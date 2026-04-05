
public class RegistroCalificado
{
    public int Codigo { get; set; }          // PK
    public int CantCreditos { get; set; }
    public string Area { get; set; }
    public string Metodologia { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime FechaFin { get; set; }
    public int DuracionAnios { get; set; }

    // FK (relación con programa)
    public int ProgramaId { get; set; }
}