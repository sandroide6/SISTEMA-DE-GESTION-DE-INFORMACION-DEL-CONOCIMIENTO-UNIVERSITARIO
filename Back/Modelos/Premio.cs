using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("premio")]
    public class Premio
    {
        [Key]
        public int id { get; set; }

        [Required]
        public string nombre { get; set; } = string.Empty;

        public string? descripcion { get; set; }

        public DateTime? fecha { get; set; }

        public string? entidad_otorga { get; set; }

        public string? pais { get; set; }

        // FK (solo campo, sin navegación aún)
        public int programa { get; set; }
    }
}

//Cuando se tenga la tabla programa:

/* using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("premio")]
    public class Premio
    {
        [Key]
        public int id { get; set; }

        [Required]
        public string nombre { get; set; } = string.Empty;

        public string? descripcion { get; set; }

        public DateTime? fecha { get; set; }

        public string? entidad_otorga { get; set; }

        public string? pais { get; set; }

        // FK
        public int programa { get; set; }

        // Relación (Navigation Property)
        [ForeignKey("programa")]
        public Programa Programa { get; set; } = null!;
    }
}
*/