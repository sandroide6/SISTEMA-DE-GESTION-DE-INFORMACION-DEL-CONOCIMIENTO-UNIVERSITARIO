using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("docente_departamento")]
    public class DocenteDepartamento
    {
        public int id_docente { get; set; }
        public int id_depto { get; set; }
        public string dedicacion { get; set; } = string.Empty;
        public string modalidad { get; set; } = string.Empty;
        public DateTime fecha_ingreso { get; set; }
        public DateTime? fecha_salida { get; set; } 
    }
}