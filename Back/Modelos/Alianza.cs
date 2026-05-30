using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("alianza")]
    public class Alianza
    {
        [Key]
        public int id { get; set; }
        public string tipo { get; set; } = string.Empty;
        public DateTime fecha_inicio { get; set; }
        public DateTime? fecha_fin { get; set; } 
        public int nit_aliado { get; set; }
        public int docente_lider { get; set; }
    }
}