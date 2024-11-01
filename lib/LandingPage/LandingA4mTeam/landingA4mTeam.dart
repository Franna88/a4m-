import 'package:a4m/Constants/myColors.dart';
import 'package:a4m/LandingPage/LandingA4mTeam/signUpCards.dart';
import 'package:a4m/LandingPage/LandingA4mTeam/ui/landingHeaderStacks.dart';
import 'package:a4m/myutility.dart';
import 'package:flutter/material.dart';

class LandingA4mTeam extends StatefulWidget {
  const LandingA4mTeam({super.key});

  @override
  State<LandingA4mTeam> createState() => _LandingA4mTeamState();
}

class _LandingA4mTeamState extends State<LandingA4mTeam> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650,
      width: MyUtility(context).width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LandingHeaderStacks(
            text: 'Want To Join The A4M Team ?',
            customWidth: 630,
            boxWidth: 640,
          ),
          const SizedBox(
            height: 20,
          ),
          LandingHeaderStacks(
            text: 'Choose Your Career',
            customWidth: 430,
            boxWidth: 440,
          ),
          const SizedBox(
            height: 80,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignUpCards(
                description:
                    'Create educational learning content and assignments for our students.',
                header: 'Content Developer',
                buttonColor: Mycolors().green,
                onPressed: () {},
                image: 'images/signUp1.png',
              ),
              const SizedBox(width: 50,),
              SignUpCards(
                description:
                    'Create educational learning content and assignments for our students.',
                header: 'Lecturer',
                buttonColor: Mycolors().blue,
                onPressed: () {},
                image: 'images/signUp2.png',
              ),
              const SizedBox(width: 50,),
              SignUpCards(
                description:
                    'Create educational learning content and assignments for our students.',
                header: 'Facilitator',
                buttonColor: Mycolors().darkTeal,
                onPressed: () {},
                image: 'images/signUp3.png',
              ),
              const SizedBox(width: 50,),
              SignUpCards(
                description:
                    'Create educational learning content and assignments for our students.',
                header: 'Student',
                buttonColor: Mycolors().darkGrey,
                onPressed: () {},
                image: 'images/signUp3.png',
              ),
              
            ],
          )
        ],
      ),
    );
  }
}
