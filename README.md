# nixos-config

Config reproducible para NixOS en MacBook Pro 13" 2012.

## Estructura

```
.
├── flake.nix              # entry point, fija versiones via flake.lock
├── flake.lock             # generado automaticamente, commitear siempre
├── configuration.nix      # sistema: kernel, drivers, usuarios, servicios
├── home.nix               # usuario mikel: paquetes, dotfiles
└── hardware-configuration.nix  # generado por nixos-generate-config, no editar
```

## Instalacion desde cero

1. Arrancar desde el ISO de NixOS y montar particiones.

2. Generar la config de hardware:
   ```bash
   nixos-generate-config --root /mnt
   ```

3. Copiar este repo a `/mnt/etc/nixos/`:
   ```bash
   cp -r . /mnt/etc/nixos/
   # copiar tambien el hardware-configuration.nix generado
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/
   ```

4. Activar flakes en el instalador (si la ISO no los tiene):
   ```bash
   nix-env -iA nixos.nixFlakes
   ```

5. Instalar:
   ```bash
   nixos-install --flake /mnt/etc/nixos#nixos-btw
   ```

## Uso diario

Aplicar cambios tras editar cualquier archivo:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw
```

Actualizar nixpkgs y home-manager (actualiza flake.lock):
```bash
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw
```

Revertir al estado anterior si algo falla:
```bash
sudo nixos-rebuild switch --rollback
```

## Notas

- `hardware-configuration.nix` se genera en tu maquina y no se incluye en el repo.
  Añadelo al `.gitignore` o commitea el tuyo propio.
- Pon tu email de git en `home.nix` antes de aplicar.
- La timezone esta en `configuration.nix`, ajustala si no es Europe/Madrid.
