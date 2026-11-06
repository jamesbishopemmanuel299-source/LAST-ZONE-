#include "LastZoneCharacter.h"
#include "LastZoneArsenalComponent.h"
#include "LastZoneWeaponVisual.h"
#include "LastZoneInventoryWidget.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Components/CapsuleComponent.h"
#include "Kismet/KismetSystemLibrary.h"
#include "LastZoneRescueBeacon.h"
#include "GameFramework/PlayerController.h"
#include "Blueprint/UserWidget.h"

ALastZoneCharacter::ALastZoneCharacter()
{
    PrimaryActorTick.bCanEverTick = false;
    ArsenalComponent = CreateDefaultSubobject<ULastZoneArsenalComponent>(TEXT("ArsenalComponent"));
    GetCapsuleComponent()->InitCapsuleSize(42.f, 96.f);
    bUseControllerRotationYaw = false;
    GetCharacterMovement()->bOrientRotationToMovement = true;
    GetCharacterMovement()->MaxWalkSpeed = NormalWalkSpeed;
    GetCharacterMovement()->JumpZVelocity = 520.f;
    GetCharacterMovement()->AirControl = 0.35f;

    USpringArmComponent* Arm = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraArm"));
    Arm->SetupAttachment(RootComponent);
    Arm->TargetArmLength = 360.f;
    Arm->bUsePawnControlRotation = true;
    Arm->SocketOffset = FVector(0.f, 60.f, 65.f);

    UCameraComponent* Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
    Camera->SetupAttachment(Arm, USpringArmComponent::SocketName);
    Camera->bUsePawnControlRotation = false;
}


void ALastZoneCharacter::BeginPlay()
{
    Super::BeginPlay();
    if (GetWorld())
    {
        FActorSpawnParameters SpawnInfo;
        SpawnInfo.Owner = this;
        SpawnInfo.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
        WeaponVisual = GetWorld()->SpawnActor<ALastZoneWeaponVisual>(
            ALastZoneWeaponVisual::StaticClass(), GetActorTransform(), SpawnInfo);
        if (WeaponVisual)
        {
            WeaponVisual->AttachToComponent(GetMesh(), FAttachmentTransformRules::KeepRelativeTransform);
            WeaponVisual->SetActorRelativeLocation(FVector(34.f, 24.f, 48.f));
            WeaponVisual->SetActorRelativeRotation(FRotator(0.f, 0.f, 0.f));
            WeaponVisual->SetWeaponStyle(ArsenalComponent ? ArsenalComponent->EquippedIndex : 0);
        }
    }

    if (APlayerController* PC = Cast<APlayerController>(GetController()))
    {
        InventoryWidget = CreateWidget<ULastZoneInventoryWidget>(PC, ULastZoneInventoryWidget::StaticClass());
        if (InventoryWidget)
        {
            InventoryWidget->SetArsenalComponent(ArsenalComponent);
            InventoryWidget->AddToViewport(20);
            InventoryWidget->SetAlignmentInViewport(FVector2D(0.5f, 1.f));
            InventoryWidget->SetPositionInViewport(FVector2D(0.f, -24.f));
        }
    }
}

void ALastZoneCharacter::SetupPlayerInputComponent(UInputComponent* Input)
{
    Super::SetupPlayerInputComponent(Input);
    Input->BindAxis("MoveForward", this, &ALastZoneCharacter::MoveForward);
    Input->BindAxis("MoveRight", this, &ALastZoneCharacter::MoveRight);
    Input->BindAxis("Turn", this, &ALastZoneCharacter::Turn);
    Input->BindAxis("LookUp", this, &ALastZoneCharacter::LookUp);
    Input->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
    Input->BindAction("Jump", IE_Released, this, &ACharacter::StopJumping);
    Input->BindAction("Interact", IE_Pressed, this, &ALastZoneCharacter::Interact);
    Input->BindAction("Fire", IE_Pressed, this, &ALastZoneCharacter::FireWeapon);
    Input->BindAction("Reload", IE_Pressed, this, &ALastZoneCharacter::ReloadWeapon);
    Input->BindAction("NextWeapon", IE_Pressed, this, &ALastZoneCharacter::NextWeapon);
    Input->BindAction("PreviousWeapon", IE_Pressed, this, &ALastZoneCharacter::PreviousWeapon);
    Input->BindAction("Sprint", IE_Pressed, this, &ALastZoneCharacter::StartSprint);
    Input->BindAction("Sprint", IE_Released, this, &ALastZoneCharacter::StopSprint);
    Input->BindAction("Stealth", IE_Pressed, this, &ALastZoneCharacter::ToggleStealth);
}

void ALastZoneCharacter::MoveForward(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
        AddMovementInput(FRotationMatrix(Controller->GetControlRotation()).GetUnitAxis(EAxis::X), Value);
}

void ALastZoneCharacter::MoveRight(float Value)
{
    if (Controller && FMath::Abs(Value) > KINDA_SMALL_NUMBER)
        AddMovementInput(FRotationMatrix(Controller->GetControlRotation()).GetUnitAxis(EAxis::Y), Value);
}

void ALastZoneCharacter::Turn(float Value) { AddControllerYawInput(Value); }
void ALastZoneCharacter::LookUp(float Value) { AddControllerPitchInput(Value); }

void ALastZoneCharacter::StartSprint()
{
    if (!bStealthMode) GetCharacterMovement()->MaxWalkSpeed = SprintWalkSpeed;
}

void ALastZoneCharacter::StopSprint()
{
    GetCharacterMovement()->MaxWalkSpeed = bStealthMode ? StealthWalkSpeed : NormalWalkSpeed;
}

void ALastZoneCharacter::ToggleStealth()
{
    bStealthMode = !bStealthMode;
    GetCharacterMovement()->MaxWalkSpeed = bStealthMode ? StealthWalkSpeed : NormalWalkSpeed;
    UKismetSystemLibrary::PrintString(this, bStealthMode ? TEXT("STEALTH: QUIET MOVEMENT") : TEXT("STEALTH OFF"),
        true, true, FLinearColor(0.2f, 0.9f, 1.f), 2.f);
}

void ALastZoneCharacter::SetScoutAlert(bool bAlerted)
{
    UKismetSystemLibrary::PrintString(this, bAlerted ? TEXT("SCOUT ALERTED — HIDE OR MOVE OUT OF SIGHT") :
        TEXT("SCOUT SEARCH ENDED"), true, true, bAlerted ? FLinearColor::Yellow : FLinearColor::Green, 2.f);
}

void ALastZoneCharacter::AddSupply(int32 Amount)
{
    SuppliesCollected += FMath::Max(0, Amount);
    UKismetSystemLibrary::PrintString(this,
        FString::Printf(TEXT("SUPPLIES: %d / 5"), SuppliesCollected), true, true,
        FLinearColor(0.2f, 0.9f, 1.f), 3.f);
}

void ALastZoneCharacter::ActivateRescueBeacon()
{
    if (SuppliesCollected < 5)
    {
        UKismetSystemLibrary::PrintString(this, TEXT("Collect 5 supply caches before activating the rescue beacon."),
            true, true, FLinearColor::Yellow, 3.f);
        return;
    }
    bRescueBeaconActivated = true;
    UKismetSystemLibrary::PrintString(this, TEXT("RESCUE SIGNAL ACTIVE — MISSION COMPLETE!"),
        true, true, FLinearColor::Green, 8.f);
}

void ALastZoneCharacter::Interact()
{
    FVector Start = GetActorLocation() + FVector(0.f, 0.f, 50.f);
    FVector End = Start + GetActorForwardVector() * 260.f;
    FHitResult Hit;
    FCollisionQueryParams Params;
    Params.AddIgnoredActor(this);
    if (GetWorld()->LineTraceSingleByChannel(Hit, Start, End, ECC_Visibility, Params))
    {
        if (ALastZoneRescueBeacon* Beacon = Cast<ALastZoneRescueBeacon>(Hit.GetActor()))
            Beacon->TryActivate(this);
    }
}

void ALastZoneCharacter::FireWeapon()
{
    if (ArsenalComponent) ArsenalComponent->FireArcadePulse();
    if (WeaponVisual) WeaponVisual->PlayFireAnimation();
    if (InventoryWidget) InventoryWidget->RefreshInventory();
}

void ALastZoneCharacter::ReloadWeapon()
{
    if (ArsenalComponent) ArsenalComponent->ReloadArcadeWeapon();
    if (WeaponVisual) WeaponVisual->PlayReloadAnimation();
    if (InventoryWidget) InventoryWidget->RefreshInventory();
}

void ALastZoneCharacter::NextWeapon()
{
    if (ArsenalComponent) ArsenalComponent->EquipNext();
    if (WeaponVisual) WeaponVisual->SetWeaponStyle(ArsenalComponent ? ArsenalComponent->EquippedIndex : 0);
    if (InventoryWidget) InventoryWidget->RefreshInventory();
}

void ALastZoneCharacter::PreviousWeapon()
{
    if (ArsenalComponent) ArsenalComponent->EquipPrevious();
    if (WeaponVisual) WeaponVisual->SetWeaponStyle(ArsenalComponent ? ArsenalComponent->EquippedIndex : 0);
    if (InventoryWidget) InventoryWidget->RefreshInventory();
}
