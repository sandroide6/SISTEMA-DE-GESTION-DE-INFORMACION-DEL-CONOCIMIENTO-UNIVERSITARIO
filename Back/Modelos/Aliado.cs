using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("aliado")]
    public class Aliado
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)] 
        public int nit { get; set; }

        public string razon_social { get; set; } = string.Empty;
        public string nombre_contacto { get; set; } = string.Empty;
        public string correo { get; set; } = string.Empty;
        public string telefono { get; set; } = string.Empty;
        public string ciudad { get; set; } = string.Empty;
    }
}