# 🎨 Rofi - Temas Modernos

Coleção de temas elegantes para o Rofi que combinam com sua barra Qtile Dracula.

## 📁 Temas Disponíveis

### 1. **Dracula Modern** (Padrão)
- **Arquivo**: `themes/dracula-modern.rasi`
- **Estilo**: Material Design com transparência
- **Cores**: Tema Dracula completo
- **Características**:
  - Transparência real (95%)
  - Cantos arredondados (16px)
  - Borda colorida (roxo Dracula)
  - Ícones grandes (28px)
  - Campo de busca destacado
  - Animações suaves

### 2. **Minimal Glass**
- **Arquivo**: `themes/minimal-glass.rasi`
- **Estilo**: Ultra-minimalista com efeito vidro
- **Características**:
  - Design super limpo
  - Janela menor (500x400)
  - Cantos mais arredondados (20px)
  - Sem prompts visuais
  - Foco total no conteúdo

### 3. **Transparente** (Legado)
- **Arquivo**: `themes/transparente.rasi`
- **Estilo**: Tema original transparente
- **Características**:
  - Máxima simplicidade
  - Transparência 50%
  - Azul de destaque

## 🚀 Como Usar

### Alternar Temas
```bash
# Ativar tema Dracula (padrão)
~/.config/rofi/switch-theme.sh dracula

# Ativar tema minimalista
~/.config/rofi/switch-theme.sh minimal

# Ativar tema transparente
~/.config/rofi/switch-theme.sh transparente

# Ver ajuda
~/.config/rofi/switch-theme.sh help
```

### Testar Rofi
```bash
# Mostrar aplicativos
rofi -show drun

# Mostrar janelas abertas
rofi -show window

# Executar comandos
rofi -show run
```

### Configuração no Qtile
No seu `config.py` do Qtile, o comando já está configurado:
```python
Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Menu"),
```

## 🎨 Personalização

### Alterar Cores
Edite o arquivo do tema desejado e modifique as variáveis de cor:
```css
* {
    bg: #282a36;           /* Fundo principal */
    blue: #bd93f9;         /* Cor de destaque */
    selected: rgba(...);   /* Seleção */
}
```

### Ajustar Tamanho
Modifique as dimensões na seção `window`:
```css
window {
    width: 600px;    /* Largura */
    height: 500px;   /* Altura */
}
```

### Personalizar Fonte
```css
configuration {
    font: "JetBrainsMono Nerd Font 12";
}
```

## 🎯 Características dos Temas

| Tema | Tamanho | Transparência | Cantos | Ícones | Estilo |
|------|---------|---------------|--------|---------|--------|
| **Dracula Modern** | 600x500 | 95% | 16px | 28px | Completo |
| **Minimal Glass** | 500x400 | 90% | 20px | 24px | Minimalista |
| **Transparente** | Dinâmico | 50% | 12px | Padrão | Simples |

## 🔧 Problemas Comuns

### Ícones não aparecem
```bash
# Instalar tema de ícones
sudo dnf install papirus-icon-theme

# Ou configurar outro tema
# No arquivo .rasi, modificar:
icon-theme: "Papirus-Dark";
```

### Fonte não funciona
```bash
# Verificar fontes instaladas
fc-list | grep -i nerd

# Se não houver, instalar:
# (JetBrains Mono Nerd Font já foi instalada)
```

### Transparência não funciona
- Certifique-se de ter um compositor ativo (picom, etc.)
- Verifique se `transparency: "real";` está configurado

## 🎊 Resultado

Agora você tem um Rofi moderno que combina perfeitamente com sua barra Qtile:
- **Visual consistente** com o tema Dracula
- **Transparência elegante** 
- **Múltiplas opções** de estilo
- **Fácil alternância** entre temas
- **Totalmente personalizável**

Aproveite seu novo launcher! 🚀