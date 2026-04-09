using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("enfoque")]
    public class Enfoque
    {
        [Key]
        public int id { get; set; }

        public string nombre { get; set; } = string.Empty;

        public string? descripcion { get; set; }
    }
}