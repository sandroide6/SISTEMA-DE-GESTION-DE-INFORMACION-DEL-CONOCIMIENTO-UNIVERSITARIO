using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("pasantia")]
    public class Pasantia
    {
        [Key]
        public int id { get; set; }

        [Required]
        public string nombre { get; set; } = string.Empty;

        public string pais { get; set; } = string.Empty;
        
        public string empresa { get; set; } = string.Empty;

        public string descripcion { get; set; } = string.Empty;

        public int id_programa { get; set; }
    }
}