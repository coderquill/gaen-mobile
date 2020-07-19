import React, { useContext } from "react"
import { StyleSheet } from "react-native"
import { useTranslation } from "react-i18next"

import PermissionsContext from "../bt/PermissionsContext"
import { useOnboardingContext } from "../OnboardingContext"
import { useStatusBarEffect } from "../navigation"
import ExplanationScreen, { IconStyle } from "./ExplanationScreen"

import { Icons, Images } from "../assets"
import { Colors } from "../styles"

export const EnableExposureNotifications = (): JSX.Element => {
  const { t } = useTranslation()
  const { exposureNotifications } = useContext(PermissionsContext)
  const { setOnboardingIsComplete } = useOnboardingContext()

  useStatusBarEffect("dark-content")

  const headerText = t("label.launch_exposure_notif_header")
  const bodyText = t("label.launch_exposure_notif_subheader")
  const buttonLabel = t("label.launch_enable_exposure_notif")
  const disableButtonLabel = t("label.launch_disable_exposure_notif")

  const handleOnPressEnable = () => {
    exposureNotifications.request()
    setOnboardingIsComplete()
  }

  const handleOnPressDontEnable = () => {
    setOnboardingIsComplete()
  }

  const explanationScreenContent = {
    backgroundImage: Images.BlueGradientBackground,
    icon: Icons.ExposureIcon,
    header: headerText,
    body: bodyText,
    primaryButtonLabel: buttonLabel,
    secondaryButtonLabel: disableButtonLabel,
  }

  const explanationScreenStyles = {
    headerStyle: styles.header,
    bodyStyle: styles.body,
    iconStyle: IconStyle.Blue,
  }

  const explanationScreenActions = {
    primaryButtonOnPress: handleOnPressEnable,
    secondaryButtonOnPress: handleOnPressDontEnable,
  }

  return (
    <ExplanationScreen
      explanationScreenContent={explanationScreenContent}
      explanationScreenStyles={explanationScreenStyles}
      explanationScreenActions={explanationScreenActions}
    />
  )
}

const styles = StyleSheet.create({
  header: {
    color: Colors.white,
  },
  body: {
    color: Colors.white,
  },
})