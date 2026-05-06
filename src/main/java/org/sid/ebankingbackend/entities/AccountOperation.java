package org.sid.ebankingbackend.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.sid.ebankingbackend.enums.OperationType;
import org.springframework.data.annotation.Id;

import java.util.Date;
@Entity
@Data @NoArgsConstructor @AllArgsConstructor
public class AccountOperation {
    @Id @GeneratedValue
    private long id;
    private Date operationDate;
    private double amount;
    private OperationType type;
    @ManyToOne
    private  BankAccount bankAccount;

}
