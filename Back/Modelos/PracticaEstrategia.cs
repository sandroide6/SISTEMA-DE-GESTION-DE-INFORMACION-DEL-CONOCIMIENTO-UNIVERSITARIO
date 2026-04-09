using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("practica_estrategia")]
    public class PracticaEstrategia
    {
        [Key]
        public int id { get; set; }

        [Required]
        public string nombre { get; set; } = string.Empty;

        public string? descripcion { get; set; }
    }
}