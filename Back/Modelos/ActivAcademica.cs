
public class ActivAcademica
{
    public int Id { get; set; }              // PK
    public string Nombre { get; set; }
    public int NumCreditos { get; set; }
    public string Tipo { get; set; }
    public string AreaFormacion { get; set; }
    public string Descripcion { get; set; }

    // FK (relación con programa)
    public int ProgramaId { get; set; }
}