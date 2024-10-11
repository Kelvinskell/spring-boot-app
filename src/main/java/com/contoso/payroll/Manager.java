package com.contoso.payroll;

import java.util.Arrays;
import java.util.Objects;

import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
public class Manager {

    public static final PasswordEncoder PASSWORD_ENCODER = new BCryptPasswordEncoder();

    private @Id @GeneratedValue Long id;

    private String name;

    private @JsonIgnore String password;

    // Store roles as a comma-separated string
    @Column(name = "roles")
    private String roles; // Change this to String

    public void setPassword(String password) {
        this.password = PASSWORD_ENCODER.encode(password);
    }

    protected Manager() {}

    public Manager(String name, String password, String... roles) {
        this.name = name;
        this.setPassword(password);
        this.roles = String.join(",", roles); // Store roles as a comma-separated string
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Manager manager = (Manager) o;
        return Objects.equals(id, manager.id) &&
            Objects.equals(name, manager.name) &&
            Objects.equals(password, manager.password) &&
            Objects.equals(roles, manager.roles); // Updated to compare as a string
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, password, roles); // Updated to include roles in hash code
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    // Convert comma-separated string back to an array
    public String[] getRoles() {
        return roles.split(","); // Return as an array
    }

    public void setRoles(String... roles) {
        this.roles = String.join(",", roles); // Store as a comma-separated string
    }

    @Override
    public String toString() {
        return "Manager{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", roles=" + Arrays.toString(getRoles()) + // Call getRoles to display as an array
            '}';
    }
}

