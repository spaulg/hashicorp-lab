plugin "docker" {
  gc {
    # Defaults to true. Changing this to false will prevent Nomad from removing images
    # from stopped tasks.
    image = false
  }
}
